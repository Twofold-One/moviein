#!/bin/bash
set -eu

# ==================================================================================== #
# VARIABLES
# ==================================================================================== #

TIMEZONE=Europe/Moscow
USERNAME=moviein

read -p "Enter password for moviein DB user: " DB_PASSWORD

export LC_ALL=en_US.UTF-8

# ==================================================================================== #
# SCRIPT LOGIC
# ==================================================================================== #

add-apt-repository --yes universe

apt update
apt --yes -o Dpkg::Options::="--force-confnew" upgrade

# Set the system timezone and install all locales.
timedatectl set-timezone ${TIMEZONE}
apt --yes install locales-all

useradd --create-home --shell "/bin/bash" --groups sudo ${USERNAME}

passwd --delete "${USERNAME}"
chage --lastday 0 "${USERNAME}"

rsync --archive --chown=${USERNAME}:${USERNAME} /root/.ssh /home/${USERNAME}

# Configure the firewall to allow SSH, HTTP and HTTPS traffic.
ufw allow 22
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

apt --yes install fail2ban

curl -L https://github.com/golang-migrate/migrate/releases/download/v4.14.1/migrate.linux-amd64.tar.gz | tar xvz
mv migrate.linux-amd64 /usr/local/bin/migrate

apt --yes install postgresql

sudo -i -u postgres psql -c "CREATE DATABASE moviein"
sudo -i -u postgres psql -d moviein -c "CREATE EXTENSION IF NOT EXISTS citext"
sudo -i -u postgres psql -d moviein -c "CREATE ROLE moviein WITH LOGIN PASSWORD '${DB_PASSWORD}'"

echo "MOVIEIN_DB_DSN='postgres://moviein:${DB_PASSWORD}@localhost/moviein'" >> /etc/environment

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt --yes install caddy

echo "Script complete! Rebooting..."
reboot