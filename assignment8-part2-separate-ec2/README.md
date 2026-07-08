# Assignment 8 - Part 2: Flask & Express on Separate EC2 Instances

Deploys the Flask backend and Express frontend on two separate EC2 instances,
communicating over their public IPs.

## Instances
- Flask backend: EC2 instance running on port 5000
- Express frontend: EC2 instance running on port 3000, calls the Flask
  instance's public IP directly (hardcoded in public/index.html)

## Run
Backend (on its instance):
cd backend
pip3 install -r requirements.txt
python3 app.py
Frontend (on its instance):
npm install
node server.js
Make sure both instances' security groups allow inbound traffic on their
respective ports (5000 for Flask, 3000 for Express) plus SSH (22).
