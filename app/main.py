"""Petite application Flask instrumentée pour Prometheus."""
import os
import socket
import time

from flask import Flask, Response, jsonify, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

app = Flask(__name__)

REQUESTS = Counter(
    "http_requests_total",
    "Nombre total de requêtes HTTP",
    ["method", "endpoint", "status"],
)
LATENCY = Histogram(
    "http_request_duration_seconds",
    "Durée des requêtes HTTP en secondes",
    ["endpoint"],
)


@app.before_request
def start_timer():
    request.environ["start_time"] = time.perf_counter()


@app.after_request
def record_metrics(response):
    if request.path == "/metrics":
        return response
    endpoint = request.url_rule.rule if request.url_rule else "unmatched"
    start = request.environ.get("start_time", time.perf_counter())
    LATENCY.labels(endpoint).observe(time.perf_counter() - start)
    REQUESTS.labels(request.method, endpoint, str(response.status_code)).inc()
    return response


@app.get("/")
def home():
    return jsonify(
        message="Bonjour depuis Kubernetes",
        pod=socket.gethostname(),
        version=os.environ.get("APP_VERSION", "dev"),
    )


@app.get("/healthz")
def healthz():
    return jsonify(status="ok")


@app.get("/fail")
def fail():
    """Génère une erreur 500 pour tester l'alerte sur le taux d'erreurs."""
    return jsonify(error="erreur volontaire"), 500


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)
