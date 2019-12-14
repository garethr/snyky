import os
import structlog
import log_helper

timestamper = structlog.processors.TimeStamper(fmt="%Y-%m-%d %H:%M:%S")
pre_chain = [
    structlog.stdlib.add_log_level,
    structlog.stdlib.add_logger_name,
    timestamper,
    log_helper.combined_logformat,
]

logconfig_dict = {
    "version": 1,
    "disable_existing_loggers": True,
    "formatters": {
        "json_formatter": {
            "()": structlog.stdlib.ProcessorFormatter,
            "processor": structlog.processors.JSONRenderer(),
            "foreign_pre_chain": pre_chain,
        }
    },
    "handlers": {
        "console": {"class": "logging.StreamHandler", "formatter": "json_formatter"}
    },
    "root": {"handlers": ["console"], "propagate": False, "level": "INFO"},
    "loggers": {
        "gunicorn.access": {
            "handlers": ["console"],
            "propagate": False,
            "level": "INFO",
        },
        "gunicorn.error": {
            "handlers": ["console"],
            "propagate": False,
            "level": "INFO",
        },
    },
}

capture_output = True
access_logfile = "-"
log_file = "-"
workers = 2
threads = 4
worker_class = "gthread"
woker_tmp_dir = "/dev/shm"
port = os.getenv('PORT') or 8000
bind = ":%s" % port
