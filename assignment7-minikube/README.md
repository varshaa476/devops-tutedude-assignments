# Assignment 7 - Flask and Express on Kubernetes (Minikube)

Deploys the Flask backend and Express frontend to a local Kubernetes
cluster running via Minikube on an EC2 instance (none driver, containerd
runtime, due to memory constraints on the free tier).

## Images
Both images are pulled directly from Docker Hub:
- varshaaa14/flask-backend:latest
- varshaaa14/express-frontend:latest

## Manifests
- flask-deployment.yaml: Deployment + ClusterIP/NodePort Service for Flask (port 5000, NodePort 30081)
- express-deployment.yaml: Deployment + NodePort Service for Express (port 3000, NodePort 30080)

## Deploy
kubectl apply -f flask-deployment.yaml
kubectl apply -f express-deployment.yaml
kubectl get pods
kubectl get svc

## Notes
The Express frontend's client-side JS was patched inside the running pod
to call the Flask service's NodePort (30081) instead of port 5000, since
only NodePort-exposed ports are reachable from outside the cluster.

## Access
http://<ec2-public-ip>:30080
