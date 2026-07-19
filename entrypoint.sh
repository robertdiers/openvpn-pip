#!/bin/sh

# 1. Dynamische Python-Pakete installieren, falls per ENV übergeben
if [ -n "$PIP_PACKAGES" ]; then
    echo "Installiere zusätzliche Python-Pakete: $PIP_PACKAGES ..."
    # --no-cache-dir spart Platz im Container-Dateisystem
    pip install --no-cache-dir $PIP_PACKAGES
fi

# 2. OpenVPN Konfigurations-Check
if [ ! -f "/etc/openvpn/vpn.ovpn" ]; then
    echo "Fehler: Keine vpn.ovpn gefunden!"
    exit 1
fi

echo "Starte OpenVPN im Hintergrund..."
openvpn --cd /etc/openvpn --config /etc/openvpn/vpn.ovpn --script-security 2 &

# 3. Warten, bis das VPN-Interface bereit ist
echo "Warte auf VPN-Verbindung..."
MAX_TRIES=15
TRY=0
while [ ! -d "/sys/class/net/tun0" ]; do
    sleep 1
    TRY=$((TRY+1))
    if [ $TRY -ge $MAX_TRIES ]; then
        echo "Fehler: VPN konnte keine Verbindung aufbauen."
        exit 1
    fi
done

echo "VPN ist aktiv!"

# 4. Übergabe an das eigentliche Command (z.B. dein Python-Skript)
exec "$@"

