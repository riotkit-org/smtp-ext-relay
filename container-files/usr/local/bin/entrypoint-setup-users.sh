#!/bin/bash
set -e

echo " >> Setting up users"
sleep 5

export PYTHONUNBUFFERED=1
export PYTHONPATH=/opt/riotkit
source /var/lib/venv/bin/activate

python -m setupusers --env-prefix USER_
cd /etc/postfix && postmap lmdb:sasl_passwd

sleep infinity
