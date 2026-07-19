#!/bin/sh

# 1. Dynamische Python-Pakete installieren
if [ -n "$PIP_PACKAGES" ]; then
    echo "Installiere zusätzliche Python-Pakete: $PIP_PACKAGES ..."
    pip install --no-cache-dir $PIP_PACKAGES
fi

# 2. VOR dem VPN-Start: Das originale Docker-Gateway auslesen
ORIGINAL_GW=$(ip route show | grep default | awk '{print $3}')
echo "Originales Docker-Gateway gesichert: $ORIGINAL_GW"

# 3. OpenVPN Konfigurations-Check
if [ ! -f "/etc/openvpn/vpn.ovpn" ]; then
    echo "Fehler: Keine vpn.ovpn gefunden!"
    exit 1
fi

echo "Starte OpenVPN im Hintergrund..."
openvpn --cd /etc/openvpn --config /etc/openvpn/vpn.ovpn --script-security 2 &

# 4. Warten, bis das VPN-Interface bereit ist
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

# 5. ROUTING-FIX: Lokalen Datenverkehr am VPN vorbeileiten
# Das sorgt dafür, dass Antworten an dein Heimnetzwerk nicht ins VPN geschickt werden.
if [ -n "$ORIGINAL_GW" ]; then
    echo "Richte lokale Routen über $ORIGINAL_GW ein..."
    ip route add 192.168.0.0/16 via "$ORIGINAL_GW" dev eth0 2>/dev/null
    ip route add 10.0.0.0/8 via "$ORIGINAL_GW" dev eth0 2>/dev/null
fi

# 6. TrueNAS-String-Fix
if [ $# -eq 1 ]; then
    echo "TrueNAS-Kommando erkannt. Bereite Argumente vor..."
    eval "set -- $1"
fi

exec "$@"
