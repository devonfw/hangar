#!/bin/bash
set -e
# shellcheck source=/dev/null
mv venv /venv
# shellcheck source=/dev/null
. /venv/bin/activate
python -m unittest