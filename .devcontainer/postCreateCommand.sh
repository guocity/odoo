#!/bin/bash
set -e # exit immediately if a command exits with a non-zero status.
set -x # enables debug mode, which prints each command to standard error before executing it.

# Retry APT install up to 2 times
for i in 1 2; do
    # Clear APT cache and update
    sudo apt-get clean
    sudo rm -rf /var/lib/apt/lists/*
    sudo apt-get update --fix-missing

    # Fix broken dependencies
    sudo apt --fix-broken install -y
    sudo apt-get install -y --fix-missing \
        libldap2-dev libsasl2-dev postgresql postgresql-client libpq-dev && break
    echo "APT install failed, retrying ($i/2)..."
    sleep 1
done
# add vscode user to sudoers
echo "vscode ALL=(postgres) NOPASSWD: /usr/bin/psql" | sudo tee /etc/sudoers.d/90-vscode-postgres

sudo service postgresql start
# create user
sudo -u postgres psql -c "CREATE USER vscode WITH PASSWORD '';"
# add to super user
sudo -u postgres psql -c "DO \$\$BEGIN IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'vscode') THEN CREATE ROLE vscode WITH LOGIN; RAISE NOTICE 'Role vscode created.'; ELSE RAISE NOTICE 'Role vscode already exists.'; END IF; END\$\$; ALTER ROLE vscode SUPERUSER;"

pip install uv
sudo uv pip install --system -r requirements.txt || echo 'No requirements.txt found, skipping dependency installation'
