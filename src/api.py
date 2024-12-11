from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    """home api endpoint"""
    return jsonify({"message": "Welcome to api"})


@app.route("/hello/<name>")
def hello(name):
    """hello api endpoint"""
    return jsonify({"message": f"Hello, {name}!"})


@app.route("/healthcheck")
def healthcheck():
    """healthcheck api endpoint"""
    return jsonify(status="OK"), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
