FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

# Utilisateur non root (UID numérique, requis par runAsNonRoot dans Kubernetes)
USER 10001

EXPOSE 8000

# Un seul worker : les compteurs prometheus_client vivent en mémoire par processus,
# plusieurs workers donneraient des métriques incohérentes d'un scrape à l'autre.
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "1", "--threads", "4", "main:app"]
