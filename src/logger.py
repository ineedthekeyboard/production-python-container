import logging
import logging.handlers
import sys
import os
LOGGER_NAME = 'api-logger'
DEBUG = \
    os.getenv("ENVIRONMENT") == "development" \
    or os.getenv("ENVIRONMENT") == "local" \
    or os.getenv("ENVIRONMENT") is None \
    or os.getenv("DEBUG_LOGS") == "true"


class LogWrapper:
    def __init__(self, name):
        self.logger = logging.getLogger(LOGGER_NAME)
        self.logger.setLevel(logging.DEBUG)
        # create file handler which logs even debug messages in prod
        fh = logging.handlers.RotatingFileHandler('api_logger.log', maxBytes=500240, backupCount=5)
        fh.setLevel(logging.DEBUG)

        # create console handler with a higher log level
        # ch = logging.StreamHandler(stream=sys.stdout)

        # if DEBUG:
        #     ch.setLevel(logging.DEBUG)
        # else:
        #     ch.setLevel(logging.INFO)

        # create formatter and add it to the handlers
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        fh.setFormatter(formatter)
        # ch.setFormatter(formatter)

        # add the handlers to the logger
        self.logger.addHandler(fh)
        # self.logger.addHandler(ch)
        self.name = name

    def debug(self, msg):
        self.log('debug', msg)

    def info(self, msg):
        self.log('info', msg)

    def warning(self, msg):
        self.log('warning', msg)

    def warn(self, msg):
        self.log('warning', msg)

    def error(self, msg):
        self.log('error', msg)

    def critical(self, msg):
        self.log('critical', msg)

    def log(self, *params):
        log_levels = {
            "critical": 50,
            "error": 40,
            "warning": 30,
            "info": 20,
            "debug": 10,
            "notset": 0
        }

        incoming_level = log_levels[params[0]]
        msg = f"({params[0]} @ {self.name})  {params[1]}"
        # print("****", msg, incoming_level)
        self.logger.log(incoming_level, msg)
