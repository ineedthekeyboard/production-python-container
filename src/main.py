from flask import Flask
app = Flask(__name__)


@app.route("/api/")
@app.route("/api/test")
def home():
    print("called")

    return "Hello World!"


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    app.run(host='localhost', port=8080)

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
