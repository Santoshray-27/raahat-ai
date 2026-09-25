import urllib.request
import urllib.error
import json
import sys
import time
import subprocess
import os

payload = {
  "user_query": "My car has a flat tyre and I need a nearby puncture repair shop",
  "message": "My car has a flat tyre",
  "location": {
    "latitude": 22.7196,
    "longitude": 75.8577,
    "accuracy_meters": 10,
    "altitude_meters": 0,
    "heading_degrees": 0,
    "speed_mps": 0
  },
  "user_id": "demo-user",
  "language": "en",
  "vehicle_info": {
    "vehicle_type": "FOUR_WHEELER",
    "make": "Maruti",
    "model": "Swift",
    "fuel_type": "PETROL"
  }
}

req = urllib.request.Request(
    'http://127.0.0.1:8000/api/v1/emergency-assistance', 
    data=json.dumps(payload).encode('utf-8'),
    headers={'Content-Type': 'application/json'},
    method='POST'
)

def test_api():
    try:
        with urllib.request.urlopen(req) as response:
            print("HTTP Status:", response.status)
            if response.status == 200:
                print("Smoke test passed: HTTP 200")
                resp_json = json.loads(response.read().decode('utf-8'))
                if "data" in resp_json:
                    data = resp_json["data"]
                    print("Contains incident:", "incident" in data)
                    print("Contains services:", "services" in data)
                    print("Contains recommended_actions:", "recommended_actions" in data)
                    print("Contains ai:", "ai" in data)
            else:
                print("Failed:", response.read().decode('utf-8'))
    except urllib.error.URLError as e:
        print("API test failed:", e)

print("Running test...")
test_api()
print("Done.")
