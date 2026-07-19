FROM python:3.14-slim

# OpenVPN, curl sowie Xvfb und grundlegende Grafikbibliotheken installieren
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openvpn \
    curl \
    xvfb \
    libxi6 \
    libglib2.0-0 \
    libnss3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/openvpn

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# Standardmäßig startet eine interaktive Python-Shell, wenn kein Command übergeben wird
CMD ["python3"]
