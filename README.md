# EasyUCS Docker

This project provides a **ready-to-deploy Docker packaging of [EasyUCS](https://github.com/vesposito/easyucs)**, designed for environments where internet access is restricted or unavailable.

It automates the build of EasyUCS into a portable `easyucs.tar` Docker image archive via GitHub Actions, so you can simply transfer and load it on any offline machine.

> [!NOTE]
> EasyUCS is developed and maintained by [vesposito](https://github.com/vesposito/easyucs). This project only handles the packaging and offline distribution.

## Getting Started

### Option 1 — Use a pre-built release (recommended)

Pre-built images are automatically published as GitHub Releases whenever a new EasyUCS version is detected.

1. Go to the [Releases](https://github.com/mabuelgh/easyucs-docker/releases) page and download the latest release assets:
   - `easyucs.tar` — the Docker image archive
   - `docker_compose.yml` — the Compose file
   - `proxy_settings.json` — proxy configuration for EasyUCS

2. Transfer the files to the offline machine, then run:

   ```bash
   docker load -i easyucs.tar
   docker compose -f docker_compose.yml up -d
   ```

3. EasyUCS is now accessible at `http://<machine-ip>:5001`

> [!TIP]
> Edit `proxy_settings.json` before starting the container if your environment requires a proxy for EasyUCS outbound calls.

---

### Option 2 — Build your own release

Use this method if you want to build the image yourself, for example to embed a corporate proxy at build time.

#### With proxy

```bash
sudo docker build \
  --build-arg PROXY_URL=http://your-proxy.local:8080 \
  -t easyucs:latest \
  -f dockerfile .
sudo docker save -o easyucs.tar easyucs:latest
```

#### Without proxy (direct internet access)

```bash
sudo docker build -t easyucs:latest -f dockerfile .
sudo docker save -o easyucs.tar easyucs:latest
```

Then transfer `easyucs.tar`, `docker_compose.yml`, and `proxy_settings.json` to the offline machine and load it as described above.

#### Automated build via GitHub Actions

The workflow `.github/workflows/build-and-release.yml` runs every day at 02:00 UTC and:

1. Reads `__version__` from the upstream EasyUCS `__init__.py`
2. Checks if a release named `v{version}` already exists in this repo
3. If not, builds the Docker image and publishes a new GitHub Release with all required files

You can also trigger a build manually from the **Actions** tab using the **"Run workflow"** button (with an optional *Force build* toggle to rebuild an existing version).

---

## DNS issues

If the container cannot resolve hostnames (common in corporate or air-gapped environments), add a DNS entry to `docker_compose.yml`:

```yaml
services:
  easyucs:
    ...
    dns:
      - 171.70.168.183  # Replace with your internal DNS server
```

Then restart the container:

```bash
docker compose -f docker_compose.yml down
docker compose -f docker_compose.yml up -d
```

---

## Authors

* **Marc Abu El Ghait** — [GitHub](https://github.com/mabuelgh)

## Projects used

* [EasyUCS](https://github.com/vesposito/easyucs) by Vincent Esposito, Franck Bonneau and Marc Abu El Ghait
