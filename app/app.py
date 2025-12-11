from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def index():
    return "Hello from DevSecOps CI/CD Project!"


@app.route("/health")
def health():
    return jsonify(status="OK"), 200


@app.route("/version")
def version():
    # You can update this manually per release if you want
    return jsonify(version="v1.0.0")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
