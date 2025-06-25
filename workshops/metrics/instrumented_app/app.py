from flask import Flask
from prometheus_client import start_http_server, Counter

app = Flask(__name__)
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests')

@app.route("/")
def hello():
    REQUEST_COUNT.inc()
    return "Hello, Metrics!"

if __name__ == "__main__":
    start_http_server(8000)
    app.run(host="0.0.0.0", port=8080)
