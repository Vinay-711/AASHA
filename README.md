# AASHA — AI-Assisted Safety & Health Assistant

[![Pharmacy regressions](https://github.com/Vinay-711/AASHA/actions/workflows/pharmacy-tests.yml/badge.svg)](https://github.com/Vinay-711/AASHA/actions/workflows/pharmacy-tests.yml)

A healthcare and personal-safety **research prototype** exploring visual medication
reminders, pharmacy availability reports, and family/guardian workflows.

[Open the browser demonstration](https://vinay-711.github.io/AASHA/)

## Project status

The browser demonstration, Flutter source, backend routes, and database services
are separate parts of the prototype. A working screen does not establish that its
external integration is connected. Several API routes currently return demonstration
records or use placeholder authentication. In particular, the pharmacy HTTP routes
use mock data; the database-backed pharmacy service is tested separately.

This is not a clinically validated medication identifier, diagnostic system,
verified live pharmacy inventory, or emergency dispatch service. Medicine identity,
dosage, availability, and emergency response require appropriate human confirmation.
No measured recognition accuracy, adherence improvement, response-time guarantee,
or patient outcome is established by this repository. The SDG themes are project
motivations, not evidence of deployed impact or institutional endorsement.

## Repository map

| Path | Purpose |
| --- | --- |
| `index.html`, `404.html` | Browser demonstration entry points |
| `mobile/` | Flutter application source; see its README for setup |
| `backend/app/api/v1/` | FastAPI route prototypes |
| `backend/app/models/` | SQLAlchemy user, medication, pharmacy and alert models |
| `backend/app/services/` | Service logic, including pharmacy verification and AR experiments |
| `backend/tests/` | Service and API tests; scope varies as described below |
| `PRD.md`, `DEMO_SCRIPT.md` | Product intentions and demonstration material |

## Run the browser demonstration locally

From the repository root:

```sh
python3 -m http.server 8080
```

Open http://localhost:8080. This serves the static demonstration; it does not start
the Python API, connect Firebase, or establish a working emergency service.

## Run the pharmacy regression suite

Python 3.11 or 3.12 is used in CI. The suite uses an isolated in-memory SQLite
database and does not require Firebase, a GPU, ML model weights, or credentials.

```sh
python3 -m venv .venv
# macOS / Linux
source .venv/bin/activate
python -m pip install -r backend/requirements-pharmacy-test.txt
cd backend
python -m pytest tests/test_pharmacy_service.py -q
```

The tests exercise real SQLAlchemy reads and writes. They check that verification:

- updates only the complete medicine name at the specified pharmacy;
- handles case and surrounding whitespace without creating duplicate records;
- treats `%` and `_` literally when identifying a record to update;
- rejects empty names, oversized names, and unsupported stock states;
- invalidates cached partial searches after stock changes;
- rolls back failed commits without discarding successful cached reads.

Distance calculations are also covered. Imports fail visibly instead of being
replaced with mocks when dependencies are missing. The CI workflow runs this suite
on pull requests and pushes to `main`.

This suite does **not** establish end-to-end mobile/API authentication, AR model
accuracy, reliable notifications, or clinical safety. The existing AR API tests
accept broad status-code ranges and should not be treated as release evidence.

## Backend and mobile development

The broader dependency lists (`requirements.txt` and `backend/requirements.txt`)
contain older experimental ML packages. They are not the lightweight test environment
above and have not been verified as a reproducible production installation.
Before deployment, resolve and audit those dependencies and wire real authentication,
service-backed routes, access controls, and notification delivery.

Use synthetic data during development. Keep credentials in ignored local environment
files and never commit patient records, private contact details, service-account
JSON files, API keys, or production database contents.

## Contributions

Useful next steps include replacing mock routes with authenticated service calls,
adding end-to-end tests with synthetic fixtures, and evaluating visual recognition
on a documented held-out dataset. Include the behavior changed, reproduction steps,
checks run, and known limitations in a pull request. Keep medical claims bounded by
actual evidence.

## Component entry points

- [Flutter client setup](mobile/README.md): device-side application and configuration.
- [Pharmacy regression tests](backend/tests/test_pharmacy_service.py): database behavior covered by CI.
- [Pharmacy service](backend/app/services/pharmacy_service.py): stock verification logic.
- [Pharmacy route prototype](backend/app/api/v1/pharmacy.py): separate mock HTTP surface.

Start with the lightweight tests above before installing optional ML dependencies. This distinction matters when evaluating whether a change affects service logic, a mock route or a rendered demonstration.
