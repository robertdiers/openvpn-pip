FROM python:3.14-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends openvpn curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /etc/openvpn

# 2. Entrypoint-Skript vorbereiten
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# Standardmäßig startet eine interaktive Python-Shell, wenn kein Command übergeben wird
CMD ["python3"]
