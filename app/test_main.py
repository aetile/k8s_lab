from main import app


def test_healthz():
    client = app.test_client()
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_home_returns_pod_name():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200
    assert "pod" in response.get_json()


def test_fail_returns_500():
    client = app.test_client()
    assert client.get("/fail").status_code == 500


def test_metrics_expose_request_counter():
    client = app.test_client()
    client.get("/")
    response = client.get("/metrics")
    assert response.status_code == 200
    assert b"http_requests_total" in response.data
