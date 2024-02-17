from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/person")
def get_person():
    person = {
        "id": 1,
        "name": "John Carmack",
        "dob": "1970-08-21",
        "occupation": "doom-god"
    }
    return jsonify(person)
