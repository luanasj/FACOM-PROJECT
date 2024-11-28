from flask import Flask,request

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

from markupsafe import escape

@app.route("/<name>",methods=["GET","POST"])
def hello(name):
    return f"Hello, {escape(name)} \n request info: {request.get_json().get('pergunta')} !"









