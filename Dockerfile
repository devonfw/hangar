FROM python:3.10-slim as base

COPY pyproject.toml poetry.lock ./
COPY app ./app
COPY venv venv
COPY docker/docker-entrypoint.sh ./

EXPOSE 80

RUN chmod +x docker-entrypoint.sh

COPY main.py logging.yaml PROD.env firebase.json ./
CMD ["./docker-entrypoint.sh"]
