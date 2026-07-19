FROM python:3.14-slim

# OpenVPN, Netzwerk-Tools, FFmpeg und Browser-Abhängigkeiten installieren
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openvpn \
    curl \
    xvfb \
    ffmpeg \
    iproute2 \
    procps \
    libxi6 \
    libglib2.0-0 \
    libnss3 \
    libxcb1 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/openvpn

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# Standardmäßig startet eine interaktive Python-Shell, wenn kein Command übergeben wird
CMD ["python3"]
