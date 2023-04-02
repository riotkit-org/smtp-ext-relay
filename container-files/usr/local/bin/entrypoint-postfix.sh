#!/bin/bash
set -e
if [[ -f /var/run/proxychains ]]; then
    exec proxychains postfix start-fg
fi
exec postfix start-fg
