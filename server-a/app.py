import logging
import statistics
from datetime import datetime

import requests
from flask import Flask, render_template
from flask_apscheduler import APScheduler
from flask_socketio import SocketIO

logging.basicConfig(level=logging.INFO)

app = Flask(__name__)
socketio = SocketIO(app)

prices = []


def update():
    if prices:
        current_avg = avg()
        current_price = prices[-1]
        socketio.emit('price avg', 'Bitcoin Avg Price: ' + str(current_avg), broadcast=True)
        socketio.emit('price update', 'Bitcoin Price: ' + str(current_price), broadcast=True)


def avg():
    avg = statistics.mean(prices)
    app.logger.info('Bitcoin Avg Price: %s', avg)
    return statistics.mean(prices)


def get_price():
    response = requests.get(
        'https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC&tsyms=USD')
    new_price = response.json()
    price = new_price['BTC']['USD']
    prices.append(price)
    return price


def job():
    global prices
    get_price()
    avg()
    app.logger.info('Prices: %s ', prices)
    if len(prices) == 60:
        prices.pop(0)


@app.route("/")
def index():
    return render_template('index.html')


if __name__ == "__main__":
    scheduler = APScheduler()
    logging.getLogger('apscheduler.executors.default').setLevel(logging.WARNING)
    scheduler.add_job(next_run_time=datetime.now(), id='Price Task', func=job, trigger='interval', seconds=10)
    scheduler.add_job(next_run_time=datetime.now(), id='Update Prices', func=update, trigger='interval', seconds=1)
    scheduler.start()
    socketio.run(app, host='0.0.0.0', port=8000)
