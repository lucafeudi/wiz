import os
from flask import Flask, jsonify, request
from pymongo import MongoClient

app = Flask(__name__)

MONGO_URI = os.getenv("MONGO_URI", "mongodb://admin:SecurePassword123!@localhost:27017/todoapp?authSource=admin")
client = MongoClient(MONGO_URI)
db = client.todoapp
todos = db.todos

@app.route("/")
def index():
    # Read wizexercise.txt to prove it exists
    exercise_file_content = "Unknown"
    if os.path.exists("wizexercise.txt"):
        with open("wizexercise.txt", "r") as f:
            exercise_file_content = f.read().strip()

    all_todos = list(todos.find({}, {"_id": 0}))
    return jsonify({
        "message": "Wiz Cloud Security Exercise - Web App",
        "author": exercise_file_content,
        "todos": all_todos
    })

@app.route("/add", methods=["POST"])
def add_todo():
    data = request.json
    title = data.get("title", "Sample Task")
    todos.insert_one({"title": title, "status": "pending"})
    return jsonify({"status": "success", "title": title})

@app.route("/verify-file")
def verify_file():
    if os.path.exists("wizexercise.txt"):
        with open("wizexercise.txt", "r") as f:
            content = f.read().strip()
        return jsonify({"status": "exists", "content": content})
    return jsonify({"status": "not_found"}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
