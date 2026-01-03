# Inception

Containerized WordPress + MariaDB + Nginx stack for the 42 Inception project. Infrastructure is orchestrated with Docker Compose and ships custom Dockerfiles for each service.

## Stack Overview
- **nginx**: TLS termination and reverse proxy. Builds from `requirements/nginx/`.
- **wordpress**: PHP-FPM container serving the application code, built from `requirements/wordpress/`.
- **mariadb**: Database service initialized via `requirements/mariadb/`.
- **Volumes**: Bind-mounts under `$DATA_DIR` (defaults to `~/data`) for `web` and `database` persistence.

## Prerequisites
- Docker Engine & Docker Compose plugin
- `make`
- macOS or Linux host

## Configuration
Create `srcs/.env` with the required variables (see `srcs/.env.example` if provided). Key values:
- `DOMAIN_NAME`: hostname served by nginx (e.g., `hai.42.fr`).
- Database and WordPress credentials.

`DATA_DIR` controls where bind volumes live. Default is `$HOME/data`. Override via environment variable: `DATA_DIR=/custom/path make up`.

## Quick Start

```bash
git clone https://github.com/emily-cloud/inception.git
cd inception
cp srcs/.env.example srcs/.env
make up
```

Then visit:
https://hai.42.fr


## Usage
```bash
make up      # build and start stack
make down    # stop containers
make clean   # stop + prune dangling docker resources
make fclean  # remove containers, volumes, and local data
make logs    # follow service logs
make status  # docker compose ps
```

## Domain Binding on macOS
If your custom domain (e.g., `hai.42.fr`) does not resolve locally, map it to localhost:

1. Edit `/etc/hosts` with sudo and append:
   ```
   127.0.0.1 hai.42.fr
   ```
   Replace `127.0.0.1` with another IP if nginx listens elsewhere.
2. Flush DNS cache:
   ```bash
   sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
   ```
3. Ensure the stack is running (`make up`) and visit `https://hai.42.fr`.

If `/etc/hosts` cannot be edited (corporate policy, managed laptop, etc.), use one of these options:
- Change `DOMAIN_NAME` in `srcs/.env` to `localhost` (or another resolvable name) and rerun `make up`.
- Add a temporary DNS override via your router or a local DNS server such as `dnsmasq`.
- Access directly via IP: `https://127.0.0.1` (you must also update nginx certificates and configs accordingly).

## Accessing WordPress Admin
If you set `DOMAIN_NAME=localhost` in your `.env` file, you can access the WordPress admin panel at:

```
https://localhost/wp-admin
```

Log in with the admin credentials you set in `srcs/.env` (e.g., `WORDPRESS_ADMIN_USER` and `WORDPRESS_ADMIN_PASSWORD`).

If you use a custom domain (e.g., `hai.42.fr`), access:
```
https://hai.42.fr/wp-admin
```

## Checking MariaDB
To check the MariaDB database running in Docker:

1. Find the container name (usually `mariadb`):
   ```
   docker ps
   ```
   Look for the container named `mariadb`.

2. Connect to MariaDB inside the container:
   ```
   docker exec -it mariadb mysql -u<user> -p
   ```
   Replace `<user>` with your database username (e.g., `root` or `wpuser`). It will prompt for the password (from your `.env` file).

3. Once inside the MariaDB prompt, you can run SQL commands, like:
   ```
   SHOW DATABASES;
   ```

To check MariaDB logs:
```
docker logs mariadb
```

## Investigating Docker Volumes
To list all Docker volumes:
```
docker volume ls
```

To inspect a specific volume (e.g., for web or database data):
```
docker volume inspect <volume_name>
```

If you use bind mounts (default: `$HOME/data/web` and `$HOME/data/database`), you can view the files directly:
```
ls ~/data/web
ls ~/data/database
```

## Demo preview

This is a simple wordpress homepage

<p align="center">
   <img src="https://github.com/emily-cloud/inception/blob/main/web_screenshots/Screenshot%202026-01-03%20at%2018.19.51.png?raw=1" alt="WordPress home page" style="width:75%; max-width:900px;">
</p>
<p align="center"><em>WordPress landing page served through nginx.</em></p>


This is wordpress admin page
<p align="center">
   <img src="https://github.com/emily-cloud/inception/blob/main/web_screenshots/Screenshot%202026-01-03%20at%2018.21.22.png?raw=1" alt="WordPress admin login" style="width:75%; max-width:900px;">
</p>
<p align="center"><em>Accessing https://hai.42.fr/wp-admin with the admin credentials from srcs/.env.</em></p>

This screenshot shows how to check mariadb

<p align="center">
   <img src="https://github.com/emily-cloud/inception/blob/main/web_screenshots/Screenshot%202026-01-03%20at%2018.36.30.png?raw=1" alt="MariaDB inspection" style="width:75%; max-width:900px;">
</p>
<p align="center"><em>Inspecting the MariaDB volume with docker volume inspect and mysql CLI.</em></p>

## Troubleshooting
- **`mkdir: /home/... Operation not supported`**: ensure `DATA_DIR` points to a path you control (defaults to `$HOME/data`).
- **Cannot reach domain**: verify `/etc/hosts` entry, flush DNS, and confirm `docker compose ps` shows all services `Up`.
- **Permission issues cleaning volumes**: `make fclean` uses `sudo chown`; ensure your user has sudo access.

## Container Architecture Diagram

```
                   +-------------------+
                   |      Browser      |
                   +-------------------+
                                  |
                                  v
                   +-------------------+
                   |       nginx       |
                   |  (reverse proxy)  |
                   +-------------------+
                                  |
                                  v
                   +-------------------+
                   |     wordpress     |
                   |     (PHP-FPM)     |
                   +-------------------+
                                  |
                                  v
                   +-------------------+
                   |      mariadb      |
                   |     (database)    |
                   +-------------------+

    +-------------------+                 +--------------------+
    |    web volume     |<--------------->| nginx & wordpress  |
    +-------------------+                 +--------------------+

    +-------------------+                 +--------------------+
    |  database volume  |<--------------->|       mariadb      |
    +-------------------+                 +--------------------+
```

- **nginx**: Handles HTTPS and serves static assets from the shared `web` volume, forwarding PHP requests to WordPress.
- **wordpress**: Runs the PHP application, reads/writes uploads on the `web` volume, and queries MariaDB.
- **mariadb**: Stores WordPress data using the dedicated `database` volume.
- **Volumes**: `web` is shared by nginx and WordPress; `database` persists MariaDB data.

## Author
Developed for 42 Berlin by:
- **Huayun Ai** 

## License
This project was developed as part of the 42 curriculum and is intended for educational use.