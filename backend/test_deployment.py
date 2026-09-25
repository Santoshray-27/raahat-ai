
import subprocess
import time
import requests
import sys

print("Starting uvicorn...")
proc = subprocess.Popen(["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"])

try:
    time.sleep(5) # wait for startup
    
    print("Testing /api/v1/health...")
    r = requests.get("http://localhost:8001/api/v1/health")
    print(r.status_code, r.text)
    assert r.status_code == 200

    print("Testing /api/v1/emergency-assistance...")
    payload = {
        "message": "I am having a severe allergic reaction",
        "latitude": 22.7196,
        "longitude": 75.8577,
        "is_voice": False
    }
    r = requests.post("http://localhost:8001/api/v1/emergency-assistance", json=payload)
    print(r.status_code)
    data = r.json()
    print("Keys in response:", data.get("data", {}).keys())
    assert r.status_code == 200
    assert "incident" in data["data"]
    assert "services" in data["data"]
    assert "recommended_actions" in data["data"]
    
    print("ALL DEPLOYMENT TESTS PASSED!")
finally:
    proc.terminate()
    proc.wait()

