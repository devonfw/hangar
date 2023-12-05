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
python -m venv /venv
poetry export --without-hashes -f requirements.txt | /venv/bin/pip install -r /dev/stdin
# shellcheck source=/dev/null
. /venv/bin/activate
mypy .
poetry build && /venv/bin/pip install dist/*.whl
deactivate
mv /venv ./venv
coverage run -m unittest
coverage report
coverage xml

# Quality
# Installation of sonar scanner
apt-get update
apt-get install -y unzip wget nodejs
mkdir sonarqube -p
cd sonarqube
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.2.0.1873-linux.zip
unzip sonar-scanner-cli-4.2.0.1873-linux.zip
mv sonar-scanner-4.2.0.1873-linux /opt/sonar-scanner
cd ..
export PATH="$PATH:/opt/sonar-scanner/bin"

projectKey=$(grep -m 1 name pyproject.toml | tr -s ' ' | tr -d '"' | tr -d "'" | cut -d' ' -f3)
exclusions="venv/**,**/common/**,**/repositories/**,**/controllers/**,**/models/**,tests/**,**utils**,**main**,**router**,**/api.py,**/exceptions/**"
sonar-scanner -Dsonar.host.url="$SONAR_URL" -Dsonar.login="$SONAR_TOKEN" -Dsonar.projectKey="$projectKey" -Dsonar.sources="." -Dsonar.python.coverage.reportPaths=coverage.xml -Dsonar.exclusions="$exclusions"
