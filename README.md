# MusicIP MusicMagic

Docker image for running MusicIP MusicMagic — the classic music analysis and mix generation server — using the **headless Linux 1.8** build.

## Before you start

### Set up the config folder

Start the container once, then **stop it immediately** and set the correct ownership:

```bash
sudo chown -R 1000:1000 /path/to/config
```

Replace `1000:1000` with your `PUID:PGID` if you use different values.

> **Important:** Do this before adding any music to the database. If the permissions are wrong, MusicIP cannot write `default.m3lib` and your library data will not be saved.

## Usage

### docker-compose

```yaml
services:
  musicip:
    image: hb1964/musicip-1.8:latest
    container_name: musicip
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
    ports:
      - 10002:10002
    volumes:
      - /path/to/music:/music
      - /path/to/config:/home/musicip/.MusicMagic
    restart: unless-stopped
```

### docker run

```bash
docker run -d \
  --name musicip \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/Amsterdam \
  -p 10002:10002 \
  -v /path/to/music:/music \
  -v /path/to/config:/home/musicip/.MusicMagic \
  --restart unless-stopped \
  hb1964/musicip-1.8:latest
```

The MusicIP web interface will be available at `http://localhost:10002`.

### Music path inside MusicIP

Your music is mounted into the container at `/music`. This is the path MusicIP will use to find your library, and the "Add music folder" button on the web UI (`http://localhost:10002`) is pre-filled with it — just click Add music, no typing required for a standard setup.

If your setup differs — for example if you mounted your music volume to a different container path instead of `/music` — you'll need to change it in two places so they stay in sync:

1. **compose.yaml** — change the container-side path in the volume mount, e.g. `/path/to/music:/mymusic:ro`.
2. **Web UI** — tick "Music folder differs from /music" under Add music folder, and enter the matching path yourself (e.g. `/mymusic`).

**Fresh setup** — for a standard `/music` mount, just click Add music in the web UI; the field is already filled with `/music`.

## Parameters

| Parameter | Function |
|---|---|
| `PUID` | User ID for file permissions (default: `1000`) |
| `PGID` | Group ID for file permissions (default: `1000`) |
| `TZ` | Timezone, e.g. `Europe/Amsterdam` |
| `-p 10002:10002` | MusicIP web interface and API |
| `-v /path/to/music:/music` | Your music library |
| `-v /path/to/config:/home/musicip/.MusicMagic` | Persistent database and configuration |

## Troubleshooting

**Permission errors on volumes** — Make sure `PUID`/`PGID` match the owner of the mounted directories on the host, and that you ran the `chown` command above after the first start.

**Port conflict** — Change the host port, e.g. `-p 10003:10002`.
