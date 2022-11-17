#!/bin/bash
set -e
# shellcheck source=/dev/null
mv venv /venv
. /venv/bin/activate
python -m unittest