from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route("/submit", methods=["POST"])
def submit():
    try:
        data = request.get_json()
        name = data.get("name")
        email = data.get("email")

        if not name or not email:
            return jsonify({"error": "Name and Email are required."}), 400

        print(f"Received submission -> Name: {name}, Email: {email}")
        return jsonify({"message": "Data submitted successfully", "name": name, "email": email}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/")
def health():
    return jsonify({"status": "Flask backend is running"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
