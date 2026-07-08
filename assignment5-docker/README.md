# Assignment 5 - Docker & Docker Compose

Flask backend + Express frontend deployed as Docker containers using Docker Compose.

## Structure
- `backend/` - Flask API (port 5000)
- `frontend/` - Express app serving a form (port 3000)
- `docker-compose.yaml` - orchestrates both services on a bridge network

## Run
Frontend: http://<host>:3000
Backend: http://<host>:5000
