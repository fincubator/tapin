#!/bin/bash
set -e

python manage.py install

exec "$@"
