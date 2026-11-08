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
    libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 \
    libasound2 libpango-1.0-0 libcairo2 libnss3 libxss1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/openvpn

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# Standardmäßig startet eine interaktive Python-Shell, wenn kein Command übergeben wird
CMD ["python3"]
