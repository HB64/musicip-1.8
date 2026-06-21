# MusicIP MusicMagic

Docker image for running MusicIP MusicMagic — the classic music analysis and mix generation server — using the **headless Linux 1.8** build.

## Before you start

### 1. Download the seccomp profile

Run this command in the same directory as your `compose.yaml`:

```bash
wget https://raw.githubusercontent.com/hb64/musicip-1.8/main/seccomp.json
```

> **Why is `seccomp.json` needed?**
> MusicMagicServer is a legacy 32-bit binary that uses a Linux system call (`personality`) which Docker blocks by default. This file adds that single exception to Docker's default security profile — everything else remains unchanged. You can open and inspect the file yourself to verify this.

### 2. Set up the config folder

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
    security_opt:
      - seccomp=./seccomp.json
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
  --security-opt seccomp=./seccomp.json \
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

Your music is mounted into the container at `/music`, which stays in Linux `/music`. This is the path MusicIP will use to find your library.

**Fresh setup** — when on the MusicIP interface you see a part ""Add music folder", type :
```
/music
```
And hit the "Add" button on the right side of it.

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

**Permission errors on volumes** — Make sure `PUID`/`PGID` match the owner of the mounted directories on the host, and that you ran the `chown` command from step 2 after the first start.

**Container won't start / seccomp errors** — Make sure `seccomp.json` is present in the same directory as your `compose.yaml` and was downloaded as shown in step 1.

**Port conflict** — Change the host port, e.g. `-p 10003:10002`.
