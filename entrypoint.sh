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

# =====================================================================
# TRUENAS FIX: Falls der Befehl als ein einziger String übergeben wurde,
# splitten wir ihn hier sauber in Argumente auf.
# =====================================================================
if [ $# -eq 1 ]; then
    echo "TrueNAS-Kommando erkannt. Bereite Argumente vor..."
    eval "set -- $1"
fi

# 4. Übergabe an das eigentliche Command (z.B. dein Python-Skript)
exec "$@"

