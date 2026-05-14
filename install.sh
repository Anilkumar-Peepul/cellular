#!/bin/bash

set -e

echo "======================================="
echo " Cellular Installer Starting..."
echo "======================================="

# -----------------------------
# CHECK ROOT
# -----------------------------
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# -----------------------------
# FORCE IPV4
# -----------------------------
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

# -----------------------------
# UPDATE SYSTEM
# -----------------------------
apt update

# -----------------------------
# INSTALL PACKAGES
# -----------------------------
apt install -y \
    ppp \
    minicom \
    python3-pip \
    python3-venv \
    network-manager \
    lsof \
    psmisc \
    pkg-config \
    libsystemd-dev \
    gcc \
    python3-dev

# -----------------------------
# CREATE INSTALL DIRECTORY
# -----------------------------
mkdir -p /home/pi/cellular

# -----------------------------
# COPY PROJECT FILES
# -----------------------------
cp -r cellular/* /home/pi/cellular/

cp chatscripts/quectel-chat-connect /etc/chatscripts/
cp chatscripts/quectel-chat-disconnect /etc/chatscripts/

cp peers/quectel-ppp /etc/ppp/peers/

cp config/config.json /home/pi/cellular/

# -----------------------------
# CREATE PYTHON VENV
# -----------------------------
python3 -m venv /home/pi/cellular/venv

# -----------------------------
# INSTALL PYTHON REQUIREMENTS
# -----------------------------
/home/pi/cellular/venv/bin/pip install --upgrade pip

/home/pi/cellular/venv/bin/pip install -r requirements.txt

# -----------------------------
# ENABLE UART
# -----------------------------
CONFIG_FILE="/boot/firmware/config.txt"

grep -qxF 'enable_uart=1' $CONFIG_FILE || echo 'enable_uart=1' >> $CONFIG_FILE
grep -qxF 'dtparam=uart0=on' $CONFIG_FILE || echo 'dtparam=uart0=on' >> $CONFIG_FILE
grep -qxF 'dtoverlay=disable-bt' $CONFIG_FILE || echo 'dtoverlay=disable-bt' >> $CONFIG_FILE

systemctl disable serial-getty@ttyAMA0.service || true

# -----------------------------
# COPY SERVICES
# -----------------------------
cp services/quectel-ppp.service /etc/systemd/system/
cp services/interface-switcher.service /etc/systemd/system/

# -----------------------------
# PERMISSIONS
# -----------------------------
chmod +x /home/pi/cellular/*.py

# -----------------------------
# ENABLE SERVICES
# -----------------------------
systemctl daemon-reload

systemctl enable quectel-ppp.service
systemctl enable interface-switcher.service

# -----------------------------
# FINISH
# -----------------------------
echo "======================================="
echo " Installation Complete"
echo " Rebooting System..."
echo "======================================="

reboot
