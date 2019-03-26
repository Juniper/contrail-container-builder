import logging
import shelve
from os import getenv
import json
from urllib2 import HTTPError, URLError, Request, urlopen
from traceback import format_exc
from datetime import timedelta, datetime
from argparse import ArgumentParser
from ConfigParser import ConfigParser
from vnc_api.vnc_api import VncApi


def init_vnc_api_client():
    return VncApi(username=getenv('KEYSTONE_AUTH_ADMIN_USERNAME'),
                  password=getenv('KEYSTONE_AUTH_ADMIN_PASSWORD'),
                  tenant_name=getenv('KEYSTONE_AUTH_ADMIN_TENANT'))


class Stats(object):
    def __init__(self, client):
        self.tf_id = client.get_default_project_id()
        self.vmachines = len(client.virtual_machines_list().get(
            'virtual-machines'))
        self.vnetworks = len(client.virtual_networks_list().get(
            'virtual-networks'))
        self.vrouters = len(client.virtual_routers_list().get(
            'virtual-routers'))
        self.vm_interfaces = len(client.virtual_machine_interfaces_list().get(
            'virtual-machine-interfaces'))

    def __str__(self):
        return str({"tf_id": self.tf_id,
                    "vr": self.vrouters,
                    "vm": self.vmachines,
                    "vn": self.vnetworks,
                    "vi": self.vm_interfaces})


class Config(object):
    def __init__(self):
        self._args = self._parse_args()
        self.send_freq = self.get_stats_sending_status()
        self._parse_config()

    def get_stats_sending_status(self):
        self._client = init_vnc_api_client()
        freq_map = {"label=stats_monthly": timedelta(days=30),
                    "label=stats_weekly": timedelta(days=7),
                    "label=stats_daily": timedelta(days=1),
                    "label=stats_every_minute": timedelta(minutes=1),
                    }
        valid = freq_map.keys()
        tags = [tag["fq_name"][0] for tag in self._client.tags_list()["tags"]]
        freq = [freq_map[tag] for tag in tags if tag in valid]
        return (None if not freq else max(freq))

    @staticmethod
    def _parse_args():
        parser = ArgumentParser()
        parser.add_argument("--config-file", required=True)
        args = parser.parse_args()
        return args

    def _parse_config(self):
        config = ConfigParser()
        config.read(self._args.config_file)

        self.log_file = config.get("LOGGING", "log_file")
        log_level = {"SYS_EMERG": logging.CRITICAL,
                     "SYS_ALERT": logging.CRITICAL,
                     "SYS_CRIT": logging.CRITICAL,
                     "SYS_ERR": logging.ERROR,
                     "SYS_WARN": logging.WARNING,
                     "SYS_NOTICE": logging.info,
                     "SYS_INFO": logging.INFO,
                     "SYS_DEBUG": logging.DEBUG
                     }
        self.log_level = log_level[config.get("LOGGING", "log_level")]


class Scheduler(object):
    def __init__(self, config, meta_source="meta_data"):
        self._meta_source = meta_source
        self._config = config

    def check_job(self):
        self._meta_data = self._get_meta_data(meta_source=self._meta_source)
        if not self._meta_data:
            self._reschedule()
        elif self._meta_data["prev_send_freq"] != self._config.send_freq:
            self._reschedule()
        else:
            self.is_job = datetime.now() > self._meta_data["scheduled_job"]
        self.scheduled_job = self._meta_data["scheduled_job"]
        return self.is_job

    def _reschedule(self):
            self._meta_data = self._set_meta_data(
                config=self._config,
                meta_source=self._meta_source)
            self.is_job = False

    def _get_meta_data(self, meta_source):
        return shelve.open(meta_source)

    def _set_meta_data(self, config, meta_source):
        meta_data = shelve.open(meta_source, writeback=True)
        self.send_freq = config.send_freq
        self.scheduled_job = datetime.now() + self.send_freq
        meta_data["scheduled_job"] = self.scheduled_job
        meta_data["prev_send_freq"] = self._config.send_freq
        meta_data.close
        return meta_data

    def job_is_done(self):
        self._reschedule()


class Postman(object):
    def __init__(self, config):
        self._config = config
        self.logger = self._init_logger(log_level=self._config.log_level,
                                        log_file=self._config.log_file)
        self.logger.info("Statistics client started.")

    def work(self):
        self._is_sending_enabled = False if self._config.send_freq is None\
            else True
        if self._is_sending_enabled is True:
            self.logger.info("Statistics sending is enabled.")
            self._scheduler = Scheduler(config=self._config)
            self._is_job = self._scheduler.check_job()
            self.logger.info(
                "Scheduled job is at %s" % str(self._scheduler.scheduled_job))
            if self._is_job is True:
                self.logger.info("There is job.")
                self._vnc_api_client = init_vnc_api_client()
                self._stats = Stats(client=self._vnc_api_client)
                self._stats_server = getenv('STATS_SERVER')
                self._server_resp = self._send_stats(
                        stats=self._stats,
                        stats_server=self._stats_server)
                self.logger.info("Sending result %s" % str(self._server_resp))
                self._scheduler.job_is_done()
            else:
                self.logger.info("There is no job.")
        else:
            self.logger.info("Statistics sending is disabled.")
        self.logger.info("Statistics client ended.")

    def _init_logger(self, log_level, log_file):
        logger = logging.getLogger(name="stats_client")
        logger.setLevel(level=log_level)
        handler = logging.FileHandler(filename=log_file)
        handler.setLevel(level=log_level)
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        return logger

    def _send_stats(self, stats, stats_server):
        server_resp = {"success": False,
                       "message": ""}
        try:
            self.logger.debug("stats data %s" % str(stats))
            self.logger.debug(str("statistics server %s" % stats_server))
            req = Request(url=stats_server,
                          data=json.dumps(stats.__dict__),
                          headers={'Content-Type': 'application/json'})
            response = urlopen(url=req)
            resp_code = response.code
            self.logger.debug(str("The server response code %s" % resp_code))
            if resp_code == 201:
                server_resp["success"] = True
            elif resp_code == 200:
                server_resp["message"] = "The server response code is 200. \
Stats server response code is 201 if stats were recieved. Probably wrong\
server URI."
        except HTTPError as e:
            if e.code == 404:
                server_resp["message"] = "The server URI was not found."
            elif e.code == 400:
                server_resp["message"] = "Malformed or resubmitted data."
            else:
                server_resp["message"] = "Statistics were not recieved by server: \
            HTTP error: %s" % e.code
        except URLError as e:
            server_resp["message"] = str(e.reason[1])
        except Exception as e:
            server_resp["message"] = "Unable to send metrics (Unknown error).\
Traceback: %s" % str(format_exc())
        return server_resp


def main():
    config = Config()
    postman = Postman(config)
    postman.work()
