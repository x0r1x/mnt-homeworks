#!/usr/bin/env python3

import logging
import random
import time
import json
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

logger=logging.getLogger()
logger.setLevel(logging.DEBUG)

file_handler=logging.FileHandler('/opt/log/app.log')
stream_handler=logging.StreamHandler()

stream_formatter=logging.Formatter(
    '%(asctime)-15s %(levelname)-8s %(message)s')
file_formatter=logging.Formatter(
    "{\"time\": \"%(asctime)s\", \"name\": \"%(name)s\", \"level\": \"%(levelname)s\", \"message\": \"%(message)s\"}"
)

file_handler.setFormatter(file_formatter)
stream_handler.setFormatter(stream_formatter)

logger.addHandler(file_handler)
logger.addHandler(stream_handler)

while True:

    time.sleep(5)
    
    number = random.randrange(0, 3)

    if number == 0:
        logger.info('Hello there!!')
    elif number == 1:
        logger.warning('Hmmm....something strange')
    elif number == 2:
        logger.error('OH NO!!!!!!')
    elif number == 3:
        logger.exception(Exception('this is exception'))
