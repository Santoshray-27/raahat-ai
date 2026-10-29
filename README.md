# RAAHAT (राहत) — Roadside Assistance & Help Anytime Tool
### Intelligent Multi-Modal Emergency Triage & Autonomous Highway Assistance Network

[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=flat-square&logo=fastapi)](backend)
[![React](https://img.shields.io/badge/Frontend-React_19_TypeScript-61DAFB?style=flat-square&logo=react)](apps/web)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter_3.x-02569B?style=flat-square&logo=flutter)](apps/mobile)
[![Gemini 2.0](https://img.shields.io/badge/AI-Gemini_2.0_Flash-4285F4?style=flat-square&logo=google)](ai)
[![Sarvam AI](https://img.shields.io/badge/Voice-Sarvam_AI-FF6B6B?style=flat-square)](ai/voice)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL_PostGIS_pgvector-336791?style=flat-square&logo=postgresql)](backend)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

> **SquidHack 2026** · **Team Solution Savvy** (Problem Statement SW-17)  
> *“Turning the next highway emergency into a clear, calm, and actionable next step.”*

---

## 📌 Table of Contents
- [Executive Overview](#-executive-overview)
- [System Architecture](#-system-architecture)
- [Core Features & Innovation](#-core-features--innovation)
- [Autonomous Voice Calling Agent (Pending Deployment)](#-autonomous-voice-calling-agent-pending-deployment)
- [Multi-Provider Resilient Fallback](#-multi-provider-resilient-fallback)
- [Offline Emergency Infrastructure](#-offline-emergency-infrastructure)
- [Repository Structure](#-repository-structure)
- [API Reference](#-api-reference)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#1-fastapi-backend-setup)
  - [Web Frontend Setup](#2-react-frontend-setup)
  - [Mobile App Setup](#3-flutter-mobile-setup)
- [Environment Variables](#-environment-variables)
- [Testing & Quality Assurance](#-testing--quality-assurance)
- [Team Solution Savvy](#-team-solution-savvy)

---

## 📖 Executive Overview

**RAAHAT** (**R**oadside **A**ssistance **A**nd **H**elp **A**nytime **T**ool) is a production-grade, AI-driven emergency response platform engineered specifically for Indian national highways, remote expressways, and connectivity deadzones.

When a vehicle breaks down or a collision occurs on an isolated highway stretch, drivers face severe stress, language barriers, fragmented emergency numbers, and intermittent cell connectivity. RAAHAT solves this with:
1. **Multilingual AI Incident Triage** (Hindi, Hinglish, and English) with immediate first-aid guidance.
2. **Deterministic Multi-Provider Geospatial Fallback** ensuring 100% service uptime even if primary map APIs rate-limit or fail.
3. **Emergency Route Planning** with real-time corridor buffering for 24x7 emergency amenities.
4. **Offline Emergency Data Packs** with cryptographically verified checksums for zero-connectivity scenarios.
5. **Autonomous Voice Calling Agent** to negotiate and dispatch roadside services without driver panic.

---

## 🏛 System Architecture

```text
                                 USER ENTRY POINTS
                       ┌──────────────────────────────────┐
                       │   React Web  │  Flutter Mobile   │
                       │   (Apps/Web) │  (Apps/Mobile)    │
                       └──────────────┬───────────────────┘
                                      │ HTTP / JSON
                                      ▼
                      ┌────────────────────────────────────┐
                      │        FastAPI Gateway / Core      │
                      │  - Firebase Auth Token Validation  │
                      │  - Unified Request ID & Telemetry  │
                      │  - Standardized JSON Response Spec │
                      └─────────────────┬──────────────────┘
                                        │
           ┌────────────────────────────┼───────────────────────────┐
           ▼                            ▼                           ▼
┌──────────────────────┐   ┌────────────────────────┐  ┌────────────────────────┐
│   AI Orchestrator    │   │  Geospatial Provider   │  │   Offline Pack Engine  │
│  - Gemini 2.0 Flash  │   │        Pipeline        │  │  - Tile & GeoJSON Gen  │
│  - Sarvam AI (Voice) │   │ 1. Google Places/Routes│  │  - SHA-256 Checksums   │
│  - Groq (Llama 3)    │   │ 2. Geoapify (Fallback) │  │  - SQLite Bundle Export│
│  - Hybrid RAG Vector │   │ 3. OSM / OSRM (Free)   │  └────────────────────────┘
│  - Heuristics Rules  │   │ 4. Curated Seed Store  │
└──────────┬───────────┘   └────────────┬───────────┘
           │                            │
           └──────────────┬─────────────┘
                          ▼
        ┌──────────────────────────────────┐
        │  PostgreSQL + PostGIS + pgvector │
        │  - Highway Service Directory     │
        │  - Vectorized First-Aid SOPs     │
        │  - User Location History & Logs  │
        └──────────────────────────────────┘
```

---

## 🚀 Core Features & Innovation

### 1. Emergency SOS & Intelligent Incident Triage
- **Natural Language Input**: Handles chaotic, panicked inputs in pure Hindi, Hinglish, or English (e.g., *"Gaadi ka agla tyre phat gaya aur engine se dhuan nikal raha hai"*).
- **Severity Extraction**: Instantly categorizes severity into `CRITICAL`, `HIGH`, `MEDIUM`, or `LOW`.
- **Immediate First-Aid Protocols**: Provides life-saving "DOs and DO NOTs" (e.g., fuel leak safety, spinal injury precautions) derived from verified SOP knowledge bases (`RAG/DOMAIN-*.json`).

### 2. Multi-Tier Geospatial Services Search
- Finds verified highway services across 8 categories: `AMBULANCE`, `HOSPITAL`, `POLICE`, `FIRE_STATION`, `TOWING`, `MECHANIC`, `PUNCTURE`, `FUEL_STATION`.
- Ranks candidate services by proximity, category match confidence, and verified 24/7 operating hours.

### 3. Safe Corridor Route Planner
- Ingests start and destination coordinates (e.g., Indore to Bhopal).
- Computes optimal highway routing and automatically queries emergency services along a customizable search buffer (default: 5 km corridor radius).

### 4. Telemetry & Live Diagnostics
- Built-in provider monitoring at `/api/v1/health` and `/api/v1/providers/status`.
- Tracks real-time API latency, active fallback counts, and provider degradation states.

---

## 📞 Autonomous Voice Calling Agent (Pending Deployment)

> ⚠️ **Current Deployment Status: PRE-DEPLOYMENT / ARCHITECTURAL PROTOTYPE**  
> *The AI agentic decision flow, API contracts, verification tests, and stub endpoints are built and integrated into the backend. Live telephony dialing via PSTN/carrier SIP trunks is currently pending carrier onboarding and regulatory compliance clearance before production deployment.*

### What is the Voice Calling Agent?
During highway breakdowns, distressed drivers often cannot manually dial, negotiate prices, or articulate mile-marker coordinates to local tow-truck drivers or mechanics.

The **RAAHAT Voice Calling Agent** is an autonomous conversational agent engineered to bridge this gap:

```text
 ┌────────────────┐         ┌────────────────────────┐         ┌────────────────────────┐
 │ Stressed Driver│ ──────> │  AI Incident Analysis  │ ──────> │  Human-in-the-Loop     │
 │ "Call mechanic"│         │  Finds Nearest Vendor  │         │  Confirmation Modal    │
 └────────────────┘         └────────────────────────┘         └───────────┬────────────┘
                                                                           │ User Approves
                                                                           ▼
 ┌────────────────┐         ┌────────────────────────┐         ┌────────────────────────┐
 │ Real-Time Push │ <────── │ Structured Result Log  │ <────── │ Telephony Voice Bridge │
 │ ETA: 18 mins   │         │ Service Cost Negotiated│         │ (Sarvam STT/TTS + SIP) │
 └────────────────┘         └────────────────────────┘         └────────────────────────┘
```

### Key Technical Architecture
1. **Agent Tool Definition**:
   ```json
   {
     "tool": "call_provider",
     "action": "CALL_VENDOR",
     "target_provider_id": "prov_indore_crane_01",
     "reason": "Request flatbed towing to nearest authorised service center",
     "requires_confirmation": true
   }
   ```
2. **Strict Human-In-The-Loop (HITL) Safety Gate**:
   - The LLM cannot execute financial transactions or outbound phone calls autonomously without explicit user confirmation on the frontend UI.
   - Backend enforces confirmation tokens before emitting outbound actions.
3. **Bilingual Conversational Telephony (Hindi + English)**:
   - Built on **Sarvam AI STT & TTS** models optimized for Indian accents, regional dialects, and vehicular background noise.
   - The voice agent greets the service provider in Hindi:
     > *"Namaste, main RAAHAT emergency platform se bol raha hoon. Ek yatri Indore-Bhopal Highway KM 42 par phanse hue hain. Kya aapka tow truck available hai?"*
4. **Deterministic Intent Extraction & Dispatch Logging**:
   - The agent listens to the vendor's spoken confirmation, extracts expected arrival time (ETA), and logs the interaction via `/api/v1/actions/dispatch`.
5. **Backend Implementation Status**:
   - Contract defined in `contracts/04_RAAHAT_API_CONTRACTS_INTEGRATION_GUIDE.md`
   - Active endpoint: `POST /api/v1/actions/dispatch`
   - Voice assistance endpoint: `POST /api/v1/voice/assist`
   - Test suites: `backend/tests/test_provider_pipeline.py` (Tests 15 & 16)
   - Telephony bridge: Outbound SIP webhook integration ready for carrier plug-in (Exotel/Twilio).

---

## 🛡 Multi-Provider Resilient Fallback

To prevent service failure during life-threatening crises, RAAHAT employs an automated 4-tier fallback matrix:

```mermaid
graph TD
    A[Emergency Query Received] --> B{Google Places / Routes}
    B -- Success --> Z[Return Verified Results]
    B -- Timeout / Quota Exceeded --> C{Geoapify Platform}
    C -- Success --> Z
    C -- Timeout / Rate Limit --> D{OSM Overpass / OSRM}
    D -- Success --> Z
    D -- Empty / Unreachable --> E[Curated Verified Seed Store]
    E --> Z
```

- **Ambulance & Towing**: Defaults immediately to verified seed records and direct national helplines (`108`, `112`), since OpenStreetMap often lacks direct roadside phone pins in rural India.
- **Audit Compliance**: Completely passes zero-mock requirements (`NO_MOCK_AUDIT.md`) with zero hardcoded dummy records in production paths.

---

## 📴 Offline Emergency Infrastructure

For complete cellular blackspots (ghats, deep rural corridors):
- **Downloadable Emergency Packs**: Users pre-download micro-bundles covering specific highway segments (e.g., *NH-48 Mumbai-Pune*, *NH-52 Indore-Jaipur*).
- **Cryptographic Verification**: Every pack is stamped with a SHA-256 integrity checksum to prevent corrupted downloads.
- **Client-Side SQLite Cache**: Flutter mobile client stores regional hospital coordinates, police outposts, and emergency contact numbers directly on device storage.

---

## 📂 Repository Structure

```text
raahat/
├── apps/
│   ├── web/                    # React 19 + Vite + TypeScript web application
│   │   ├── src/
│   │   │   ├── api/client.ts   # Unified API client & type contracts
│   │   │   ├── pages/          # Dashboard, Emergency SOS, Nearby, Route Planner
│   │   │   └── components/     # UI components & Antigravity navigation
│   │   └── package.json
│   └── mobile/                 # Flutter cross-platform mobile application
│       ├── lib/                # Mobile screens, state management & offline storage
│       └── pubspec.yaml
├── backend/                    # FastAPI High-Performance Backend
│   ├── app/
│   │   ├── api/v1/             # Endpoints (emergency, voice, routes, services, rag)
│   │   ├── core/               # App configuration, security, database & telemetry
│   │   ├── providers/          # Google, Geoapify, OSM & Curated provider modules
│   │   ├── schemas/            # Pydantic v2 data transfer schemas
│   │   └── services/           # AI orchestrator, ranking algorithms, offline pack builder
│   ├── data/                   # Verified emergency seed database
│   ├── tests/                  # 15+ comprehensive pytest integration test suites
│   ├── requirements.txt
│   └── DEPLOYMENT.md
├── ai/                         # AI R&D, prompts, and agentic workflows
│   ├── agentic/                # Autonomous agent tool definitions
│   ├── rag/                    # Ingestion, retrieval, and prompt engineering
│   └── voice/                  # Sarvam voice calling agent specifications
├── RAG/                        # Verified domain emergency knowledge base (JSON)
├── contracts/                  # Single source of truth API contracts & schema specs
├── docs/                       # Technical audits, research benchmarks & reports
└── render.yaml                 # Infrastructure as Code deployment blueprint
```

---

## 📡 API Reference

Base URL: `http://localhost:8000/api/v1` (or production host)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | System health, database connectivity & mode verification |
| `POST` | `/emergency/triage` | Incident NLP classification, severity extraction & live nearby help |
| `GET` | `/services/nearby` | Proximity-based lookup with category filtering & provider fallback |
| `POST` | `/routes/plan` | Highway route calculation with emergency corridor services scanning |
| `POST` | `/voice/assist` | Speech-to-Text transcript ingestion and voice response generator |
| `POST` | `/actions/dispatch` | Dispatches roadside actions (`CALL_VENDOR`, `DISPATCH_TOWING`, etc.) |
| `GET` | `/providers/status` | Real-time health metrics of external geospatial providers |
| `POST` | `/offline-packs` | Compiles cryptographically verified offline data packages |
| `POST` | `/rag/query` | Direct semantic search across first-aid & rescue SOP database |

---

## 🛠 Getting Started

### Prerequisites
- **Python**: `3.12+`
- **Node.js**: `18.x` or `20.x`
- **Flutter SDK**: `3.x` (for mobile app)
- **PostgreSQL**: `15+` with `postgis` and `pgvector` extensions (Optional for local testing; backend automatically degrades gracefully if DB is omitted).

---

### 1. FastAPI Backend Setup

```bash
# 1. Navigate to backend directory
cd backend

# 2. Create and activate a virtual environment
python -m venv venv
# On Windows:
venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment variables
cp .env.example .env
# Edit .env and supply your API keys (Gemini, Geoapify, etc.)

# 5. Start the backend development server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
API Documentation will be live at:
- **Swagger UI**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **ReDoc**: [http://localhost:8000/redoc](http://localhost:8000/redoc)

---

### 2. React Frontend Setup

```bash
# 1. Navigate to the web application directory
cd apps/web

# 2. Install npm packages
npm install

# 3. Launch development server
npm run dev
```
Open your browser at `http://localhost:5173`.

---

### 3. Flutter Mobile Setup

```bash
# 1. Navigate to the mobile app directory
cd apps/mobile

# 2. Fetch Flutter packages
flutter pub get

# 3. Run on connected device or emulator
flutter run
```

---

## ⚙️ Environment Variables

Create a `.env` file in the `backend/` directory:

```ini
# Core Configuration
ENVIRONMENT=development
PROJECT_NAME="RAAHAT API"
VERSION="1.0.0"
PORT=8000
AUTH_DISABLED=true              # Set to false to enforce Firebase Auth tokens
USE_MOCKS=false                 # Set to true only for offline testing

# AI & LLM Provider Keys
GEMINI_API_KEY=your_gemini_api_key
SARVAM_API_KEY=your_sarvam_api_key
GROQ_API_KEY=your_groq_api_key

# Geospatial Provider Keys
GOOGLE_PLACES_API_KEY=your_google_places_key
GOOGLE_ROUTES_API_KEY=your_google_routes_key
GEOAPIFY_API_KEY=your_geoapify_key

# Database Connection (PostgreSQL + PostGIS + pgvector)
DATABASE_URL=postgresql+asyncpg://postgres:password@localhost:5432/raahat_db

# CORS Allowed Origins
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
```

---

## 🧪 Testing & Quality Assurance

RAAHAT includes a suite of end-to-end integration tests verifying every API contract, provider fallback, and error state.

```bash
# Run backend test suite
cd backend
pytest -v
```

Expected output:
```text
tests/test_provider_pipeline.py::test_health_endpoint PASSED
tests/test_provider_pipeline.py::test_emergency_triage_puncture PASSED
tests/test_provider_pipeline.py::test_emergency_triage_critical_hindi PASSED
tests/test_provider_pipeline.py::test_nearby_services_limit PASSED
tests/test_provider_pipeline.py::test_safe_routes_indore_bhopal PASSED
tests/test_provider_pipeline.py::test_offline_pack_creation PASSED
tests/test_provider_pipeline.py::test_provider_status PASSED
tests/test_provider_pipeline.py::test_voice_assist_with_explicit_location PASSED
tests/test_provider_pipeline.py::test_voice_assist_without_location_uses_curated_fallback PASSED
==================== 15 passed in ~35s ====================
```

---

## 👥 Team Solution Savvy

Developed with pride for **SquidHack 2026**:

| Team Member | Domain & Responsibilities |
|---|---|
| **Satwik Misra** | Backend Architecture, FastAPI, AI/RAG Engine, Multi-LLM Orchestration, Sarvam Voice Integration, Autonomous Voice Calling Agent |
| **Santosh Ray** | React Frontend Development, UI/UX Engineering, API Integration, Production Deployment & QA |
| **Saanvi Gupta** | Flutter Mobile Application, Cross-Platform UI, Offline Pack System & Field Research |

---

## 📜 License
This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
