#!/bin/bash
set -e
. venv/bin/activate
python -m coverage run -m unittest
coverage report