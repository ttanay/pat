from flask import Flask, jsonify, abort

app = Flask(__name__)

persons = [
    {
        "id": 1,
        "name": "John Carmack",
        "dob": "1970-08-21",
        "occupation": "doom-god"
    },
    {
        "id": 2,
        "name": "Edgar Djikstra",
        "dob": "1930-05-11",
        "occupation": "scientist"

    }
]


@app.errorhandler(404)
def resource_not_found(e):
    return jsonify(error=str(e)), 404

@app.get("/person/<int:person_id>")
def get_person(person_id):
    if person_id > len(persons):
        return abort(404, f"Person with id {person_id} not found")
    person = persons[person_id - 1]
    return jsonify(person)
