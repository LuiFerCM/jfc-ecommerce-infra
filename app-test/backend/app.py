import os
import json
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/health")
def health():
    return jsonify({"status": "healthy", "service": "jfc-ecommerce-api"}), 200

@app.route("/")
def index():
    return jsonify({
        "message": "JFC E-Commerce API",
        "version": "1.0.0",
        "environment": os.getenv("NODE_ENV", "development")
    })

@app.route("/api/products")
def products():
    return jsonify({
        "products": [
            {"id": 1, "name": "Product A", "price": 29.99},
            {"id": 2, "name": "Product B", "price": 49.99},
            {"id": 3, "name": "Product C", "price": 19.99},
        ]
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 8080)))
