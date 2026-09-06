from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "HEALTHY"
    assert "SMRITI" in data["service"]

def test_api_v1_docs_accessible():
    response = client.get("/docs")
    assert response.status_code == 200
