# Assignment 5 - Docker & Docker Compose

Flask backend + Express frontend deployed as Docker containers using Docker Compose.

## Structure
- `backend/` - Flask API (port 5000)
- `frontend/` - Express app serving a form (port 3000)
- `docker-compose.yaml` - orchestrates both services on a bridge network

## Run
Frontend: http://<host>:3000
Backend: http://<host>:5000

## Docker Hub Images
- Backend: https://hub.docker.com/r/varshaaa14/flask-backend
- Frontend: https://hub.docker.com/r/varshaaa14/express-frontend

## GitHub Repo
https://github.com/varshaa476/devops-tutedude-assignments/tree/main/assignment5-docker
