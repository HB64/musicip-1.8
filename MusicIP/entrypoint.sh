#!/bin/sh

# Create moods directory if not already present
mkdir -p /home/musicip/.MusicMagic/moods

# Copy default config files if not already present
if [ ! -f /home/musicip/.MusicMagic/mmm.ini ]; then
    cp /opt/MusicIP/mmm.ini /home/musicip/.MusicMagic/
fi

if [ ! -f /home/musicip/.MusicMagic/recipes.xml ]; then
    cp /opt/MusicIP/recipes.xml /home/musicip/.MusicMagic/
fi

echo '127.0.0.1 music.predixis.com' >> /etc/hosts
setpriv --reuid=musicip --regid=musicip --init-groups env HOME=/home/musicip /opt/MusicIP/MusicMagicServer -verbose start
sleep 3
MUSICIP_PORT=$(cat /proc/net/tcp | grep '0B00007F' | awk '{print $2}' | cut -d: -f2 | head -1 | xargs -I{} printf '%d\n' 0x{})
echo "MusicIP listening on 127.0.0.1:$MUSICIP_PORT"
socat TCP-LISTEN:10002,fork,reuseaddr TCP:127.0.0.1:$MUSICIP_PORT &
sleep infinity