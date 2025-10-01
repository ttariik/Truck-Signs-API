# Truck Signs API - Docker Setup

Dieses Projekt wurde für die Ausführung in Docker-Containern konfiguriert.

## 🔒 Sicherheitshinweise

**WICHTIG**: Dieses Repository enthält sensible Konfigurationsdateien. Bitte beachten Sie die Sicherheitsrichtlinien:

- **Niemals** `.env` Dateien mit echten Werten committen
- **Immer** `env.example` als Vorlage verwenden
- **Überprüfen** Sie die `.gitignore` Datei vor dem Commit
- **Führen** Sie `./security-check.sh` vor dem ersten Commit aus

## Voraussetzungen

- Docker
- Docker Compose

## Schnellstart

1. **Repository klonen:**
   ```bash
   git clone git@github.com:Developer-Akademie-GmbH/truck_signs_api.git
   cd truck_signs_api
   ```

2. **Sicherheitsprüfung durchführen:**
   ```bash
   ./security-check.sh
   ```

3. **Umgebungsvariablen konfigurieren:**
   ```bash
   cp env.example .env
   ```
   
   Bearbeiten Sie die `.env` Datei und setzen Sie Ihre eigenen Werte:
   - `SECRET_KEY`: Django Secret Key
   - `CLOUD_NAME`, `CLOUD_API_KEY`, `CLOUD_API_SECRET`: Cloudinary Konfiguration
   - `STRIPE_PUBLISHABLE_KEY`, `STRIPE_SECRET_KEY`: Stripe Konfiguration
   - `EMAIL_HOST_USER`, `EMAIL_HOST_PASSWORD`: E-Mail Konfiguration

4. **Container starten:**
   ```bash
   docker-compose up --build
   ```

5. **Anwendung öffnen:**
   - API: http://localhost:8000
   - Admin Panel: http://localhost:8000/admin
   - Standard Admin Login: `admin` / `admin123`

## Verfügbare Befehle

### Container starten
```bash
docker-compose up
```

### Container im Hintergrund starten
```bash
docker-compose up -d
```

### Container neu bauen
```bash
docker-compose up --build
```

### Container stoppen
```bash
docker-compose down
```

### Container mit Volumes löschen
```bash
docker-compose down -v
```

### Logs anzeigen
```bash
docker-compose logs -f
```

### Django Management Commands ausführen
```bash
# Migrations erstellen
docker-compose exec web python manage.py makemigrations

# Migrations ausführen
docker-compose exec web python manage.py migrate

# Superuser erstellen
docker-compose exec web python manage.py createsuperuser

# Django Shell
docker-compose exec web python manage.py shell
```

### Sicherheitsprüfung
```bash
# Vollständige Sicherheitsprüfung
./security-check.sh

# Pre-commit Hook testen
git add .
git commit -m "Test commit"
```

## Projektstruktur

```
truck_signs_api/
├── Dockerfile              # Docker Image Konfiguration
├── docker-compose.yml      # Multi-Container Setup
├── .dockerignore           # Dateien die ignoriert werden sollen
├── .gitignore              # Git Ignore Regeln
├── env.example             # Beispiel für Umgebungsvariablen
├── entrypoint.sh           # Container Start-Skript
├── security-check.sh       # Sicherheitsprüfungs-Skript
├── SECURITY.md             # Sicherheitsrichtlinien
├── requirements.txt        # Python Dependencies
├── manage.py              # Django Management
├── backend/               # Django App
├── truck_signs_designs/   # Django Projekt
│   └── settings/
│       ├── base.py        # Basis Settings
│       ├── docker.py      # Docker-spezifische Settings
│       ├── dev.py         # Development Settings
│       └── production.py  # Production Settings
└── templates/             # HTML Templates
```

## Services

### Web Service (Django)
- **Port:** 8000
- **Image:** Custom build from Dockerfile
- **Volumes:** 
  - Code wird gemountet für Development
  - Static und Media Files als Volumes

### Database Service (PostgreSQL)
- **Port:** 5432
- **Image:** postgres:13
- **Database:** truck_signs_db
- **User:** postgres
- **Password:** postgres

## Entwicklung

Für die Entwicklung wird der Code als Volume gemountet, sodass Änderungen sofort sichtbar sind.

### Hot Reload aktivieren
Das Django Development Server läuft standardmäßig mit Auto-Reload.

### Debugging
- Logs: `docker-compose logs -f web`
- Container betreten: `docker-compose exec web bash`

## Produktion

Für Produktionsumgebungen:

1. `DEBUG=False` in `.env` setzen
2. Starke `SECRET_KEY` generieren
3. Echte Datenbank-Credentials verwenden
4. Gunicorn statt Development Server verwenden

## Troubleshooting

### Container startet nicht
```bash
# Logs prüfen
docker-compose logs

# Container neu bauen
docker-compose up --build --force-recreate
```

### Datenbank-Verbindungsfehler
```bash
# Datenbank-Container Status prüfen
docker-compose ps db

# Datenbank-Logs prüfen
docker-compose logs db
```

### Port bereits belegt
```bash
# Andere Ports verwenden
docker-compose up -p 8001:8000
```

## Umgebungsvariablen

| Variable | Beschreibung | Standard |
|----------|--------------|----------|
| `DEBUG` | Django Debug Modus | `1` |
| `SECRET_KEY` | Django Secret Key | `django-insecure-change-me` |
| `DATABASE_URL` | PostgreSQL Verbindungsstring | `postgres://postgres:postgres@db:5432/truck_signs_db` |
| `CLOUD_NAME` | Cloudinary Cloud Name | - |
| `CLOUD_API_KEY` | Cloudinary API Key | - |
| `CLOUD_API_SECRET` | Cloudinary API Secret | - |
| `STRIPE_PUBLISHABLE_KEY` | Stripe Publishable Key | - |
| `STRIPE_SECRET_KEY` | Stripe Secret Key | - |
| `CURRENT_ADMIN_DOMAIN` | Admin Domain | `localhost:8000` |
| `EMAIL_ADMIN` | Admin E-Mail | `admin@example.com` |
| `EMAIL_HOST_USER` | SMTP Benutzername | - |
| `EMAIL_HOST_PASSWORD` | SMTP Passwort | - |
