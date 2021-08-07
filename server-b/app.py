import flask
from flask import Flask

app = Flask(__name__)


@app.route("/")
def success():
    status_code = flask.Response(status=200)
    return status_code


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True, port=8005)
