#!/bin/bash
# ===========================================
# TRUCK SIGNS API - SECURITY CHECK SCRIPT
# ===========================================
# Dieses Skript führt eine umfassende Sicherheitsprüfung durch

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Zähler
ERRORS=0
WARNINGS=0
CHECKS=0

# Funktionen
error() {
    echo -e "${RED}❌ FEHLER: $1${NC}"
    ERRORS=$((ERRORS + 1))
}

warning() {
    echo -e "${YELLOW}⚠️  WARNUNG: $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check() {
    CHECKS=$((CHECKS + 1))
    echo -e "${BLUE}🔍 Prüfe: $1${NC}"
}

# Header
echo "🔒 TRUCK SIGNS API - SICHERHEITSPRÜFUNG"
echo "========================================"
echo ""

# 1. Prüfe .gitignore
check ".gitignore Datei"
if [ ! -f ".gitignore" ]; then
    error ".gitignore Datei fehlt!"
else
    success ".gitignore Datei vorhanden"
    
    # Prüfe wichtige Einträge
    if grep -q "\.env" .gitignore; then
        success ".env in .gitignore"
    else
        error ".env nicht in .gitignore"
    fi
    
    if grep -q "Dockerfile" .gitignore; then
        success "Dockerfile in .gitignore"
    else
        warning "Dockerfile nicht in .gitignore"
    fi
    
    if grep -q "docker-compose" .gitignore; then
        success "docker-compose in .gitignore"
    else
        warning "docker-compose nicht in .gitignore"
    fi
fi

# 2. Prüfe env.example
check "env.example Datei"
if [ ! -f "env.example" ]; then
    error "env.example Datei fehlt!"
else
    success "env.example Datei vorhanden"
    
    # Prüfe auf Platzhalter
    if grep -q "your-" env.example; then
        success "Platzhalter in env.example gefunden"
    else
        warning "Keine Platzhalter in env.example gefunden"
    fi
fi

# 3. Prüfe auf .env Dateien
check "Vorhandene .env Dateien"
ENV_FILES=$(find . -name ".env*" -type f | grep -v ".git")
if [ ! -z "$ENV_FILES" ]; then
    warning "Gefundene .env Dateien:"
    echo "$ENV_FILES"
    echo "Stellen Sie sicher, dass diese nicht committet werden."
else
    success "Keine .env Dateien gefunden"
fi

# 4. Prüfe auf sensible Dateien
check "Sensible Dateien"
SENSITIVE_FILES=$(find . -type f \( -name "*.key" -o -name "*.pem" -o -name "*.crt" -o -name "*.cer" -o -name "*.der" -o -name "*.p12" -o -name "*.pfx" -o -name "*.jks" -o -name "*.keystore" \) | grep -v ".git")
if [ ! -z "$SENSITIVE_FILES" ]; then
    error "Sensible Dateien gefunden:"
    echo "$SENSITIVE_FILES"
else
    success "Keine sensiblen Dateien gefunden"
fi

# 5. Prüfe auf SSH Keys
check "SSH Keys"
SSH_KEYS=$(find . -type f \( -name "id_rsa*" -o -name "id_dsa*" -o -name "id_ecdsa*" -o -name "id_ed25519*" \) | grep -v ".git")
if [ ! -z "$SSH_KEYS" ]; then
    error "SSH Keys gefunden:"
    echo "$SSH_KEYS"
else
    success "Keine SSH Keys gefunden"
fi

# 6. Prüfe auf API Keys im Code
check "API Keys im Code"
API_KEYS=$(grep -r -E "(sk_|pk_|whsec_|AIza|AKIA)" . --exclude-dir=.git --exclude="*.md" --exclude="security-check.sh" | grep -v "example\|placeholder\|your-")
if [ ! -z "$API_KEYS" ]; then
    error "API Keys im Code gefunden:"
    echo "$API_KEYS"
else
    success "Keine API Keys im Code gefunden"
fi

# 7. Prüfe auf Passwörter im Code
check "Passwörter im Code"
PASSWORDS=$(grep -r -E "(password|passwd|pwd)\s*[:=]\s*['\"][^'\"]{8,}['\"]" . --exclude-dir=.git --exclude="*.md" --exclude="security-check.sh" | grep -v "example\|placeholder\|your-")
if [ ! -z "$PASSWORDS" ]; then
    error "Passwörter im Code gefunden:"
    echo "$PASSWORDS"
else
    success "Keine Passwörter im Code gefunden"
fi

# 8. Prüfe auf Datenbank-URLs
check "Datenbank-URLs"
DB_URLS=$(grep -r -E "postgres://[^:]+:[^@]+@" . --exclude-dir=.git --exclude="*.md" --exclude="security-check.sh" | grep -v "postgres:postgres@")
if [ ! -z "$DB_URLS" ]; then
    error "Datenbank-URLs mit echten Credentials gefunden:"
    echo "$DB_URLS"
else
    success "Keine Datenbank-URLs mit echten Credentials gefunden"
fi

# 9. Prüfe Docker-Dateien
check "Docker-Dateien"
DOCKER_FILES=$(find . -name "Dockerfile*" -o -name "docker-compose*.yml" -o -name "docker-compose*.yaml" | grep -v ".git")
if [ ! -z "$DOCKER_FILES" ]; then
    info "Gefundene Docker-Dateien:"
    echo "$DOCKER_FILES"
    echo "Stellen Sie sicher, dass keine echten Credentials enthalten sind."
else
    success "Keine Docker-Dateien gefunden"
fi

# 10. Prüfe Git-Hooks
check "Git-Hooks"
if [ -f ".git/hooks/pre-commit" ]; then
    success "Pre-commit Hook vorhanden"
    if [ -x ".git/hooks/pre-commit" ]; then
        success "Pre-commit Hook ist ausführbar"
    else
        warning "Pre-commit Hook ist nicht ausführbar"
    fi
else
    warning "Pre-commit Hook fehlt"
fi

# 11. Prüfe auf große Dateien
check "Große Dateien (>10MB)"
LARGE_FILES=$(find . -type f -size +10M | grep -v ".git")
if [ ! -z "$LARGE_FILES" ]; then
    warning "Große Dateien gefunden:"
    for file in $LARGE_FILES; do
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        echo "  $file ($(($size / 1024 / 1024))MB)"
    done
else
    success "Keine großen Dateien gefunden"
fi

# 12. Prüfe auf Backup-Dateien
check "Backup-Dateien"
BACKUP_FILES=$(find . -type f \( -name "*.backup" -o -name "*.bak" -o -name "*.old" -o -name "*.orig" -o -name "*.tmp" -o -name "*.temp" \) | grep -v ".git")
if [ ! -z "$BACKUP_FILES" ]; then
    warning "Backup-Dateien gefunden:"
    echo "$BACKUP_FILES"
    echo "Diese sollten normalerweise nicht committet werden."
else
    success "Keine Backup-Dateien gefunden"
fi

# Ergebnis
echo ""
echo "========================================"
echo "🔒 SICHERHEITSPRÜFUNG ABGESCHLOSSEN"
echo "========================================"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    success "Alle $CHECKS Prüfungen erfolgreich!"
    echo "✅ Repository ist sicher für den Commit."
    exit 0
elif [ $ERRORS -eq 0 ]; then
    success "Alle kritischen Prüfungen erfolgreich!"
    warning "$WARNINGS Warnungen gefunden"
    echo "⚠️  Repository ist sicher, aber überprüfen Sie die Warnungen."
    exit 0
else
    error "$ERRORS kritische Fehler gefunden!"
    if [ $WARNINGS -gt 0 ]; then
        warning "$WARNINGS Warnungen gefunden"
    fi
    echo "❌ Repository ist NICHT sicher für den Commit."
    echo ""
    echo "💡 Nächste Schritte:"
    echo "   1. Beheben Sie alle Fehler"
    echo "   2. Führen Sie das Skript erneut aus"
    echo "   3. Committen Sie erst nach erfolgreicher Prüfung"
    exit 1
fi
