#!/bin/bash
set -e
export PYTHONFAULTHANDLER=1
export PYTHONHASHSEED=random
export PYTHONUNBUFFERED=1
export PIP_DEFAULT_TIMEOUT=100
export PIP_DISABLE_PIP_VERSION_CHECK=1
export PIP_NO_CACHE_DIR=1
export POETRY_VERSION=1.0.5

pip install "poetry==$POETRY_VERSION"
python -m venv venv
poetry export --without-hashes -f requirements.txt | venv/bin/pip install -r /dev/stdin
. venv/bin/activate
mypy .
poetry build && venv/bin/pip install dist/*.whl