#!/bin/bash
sudo apt-get update
sudo apt-get install -y libldap2-dev libsasl2-dev postgresql postgresql-client libpq-dev
sudo service postgresql start
pip install uv
sudo uv pip install --user -r requirements.txt || echo 'No requirements.txt found, skipping dependency installation'