#!/bin/bash
set -e

cd /etc/postfix
postmap lmdb:transport
