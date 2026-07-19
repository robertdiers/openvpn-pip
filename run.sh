#!/bin/bash
set -e

docker build -t openvpn-pip .
docker run -it --name openvpn-pip-test -e PIP_PACKAGES='requests' openvpn-pip
