from flask import Flask
from logger import LogWrapper
app = Flask(__name__)
logging = LogWrapper("server")

logging.info(f"Flask APP Started!")


@app.route("/api/")
@app.route("/api/test")
def home():
    print("PRINT: API called")
    logging.info("INFO - API called")
    logging.debug("DEBUG - API called")
    logging.error("Error - API called")
    return "Hello World!"


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    app.run(host='localhost', port=8080)

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
