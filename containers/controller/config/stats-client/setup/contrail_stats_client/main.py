import logging
import shelve
from os import getenv
import json
from urllib2 import HTTPError, URLError, Request, urlopen
from traceback import format_exc
from datetime import timedelta, datetime
from argparse import ArgumentParser
from ConfigParser import ConfigParser
from time import sleep

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


class Scheduler(object):
    DEFAULT_FREQ = timedelta(days=0)

    def __init__(self):
        self._meta_source = "meta_data"
        self._is_job = False
        self._send_freq = Scheduler.DEFAULT_FREQ
        self._meta_data = None
        self.scheduled_job = None

    @property
    def send_freq(self):
        self._client = init_vnc_api_client()
        freq_map = {"label=stats_monthly": timedelta(days=30),
                    "label=stats_weekly": timedelta(days=7),
                    "label=stats_daily": timedelta(days=1),
                    "label=stats_every_minute": timedelta(minutes=1),
                    }
        valid = freq_map.keys()
        tags = [tag["fq_name"][0] for tag in self._client.tags_list()["tags"]]
        freq = [freq_map[tag] for tag in tags if tag in valid]
        self._send_freq = None if not freq else max(freq)
        return self._send_freq

    @property
    def is_job(self):
        self._is_job = False
        if not self.send_freq:
            pass
        elif (self.meta_data.get(
                "prev_send_freq", Scheduler.DEFAULT_FREQ) != self._send_freq):
            self._reschedule()
        else:
            self._is_job = datetime.now() > self._meta_data["scheduled_job"]
        return self._is_job

    def _reschedule(self):
            self.meta_data = self._send_freq
            self.scheduled_job = self._meta_data["scheduled_job"]

    @property
    def meta_data(self):
        self._meta_data = shelve.open(self._meta_source)
        return self._meta_data

    @meta_data.setter
    def meta_data(self, send_freq):
        self._meta_data = shelve.open(self._meta_source, writeback=True)
        self.scheduled_job = datetime.now() + send_freq
        self._meta_data["scheduled_job"] = self.scheduled_job
        self._meta_data["prev_send_freq"] = send_freq
        self._meta_data.close

    def job_is_done(self):
        self._reschedule()


class Postman(object):
    def __init__(self):
        self._args = self._parse_args()
        self._parse_config()
        self._logger = self._init_logger(log_level=self._log_level,
                                         log_file=self._log_file)
        self._scheduler = Scheduler()

    @staticmethod
    def _parse_args():
        parser = ArgumentParser()
        parser.add_argument("--config-file", required=True)
        args = parser.parse_args()
        return args

    def _parse_config(self):
        config = ConfigParser()
        config.read(self._args.config_file)

        self._log_file = config.get("LOGGING", "log_file")
        log_level = {"SYS_EMERG": logging.CRITICAL,
                     "SYS_ALERT": logging.CRITICAL,
                     "SYS_CRIT": logging.CRITICAL,
                     "SYS_ERR": logging.ERROR,
                     "SYS_WARN": logging.WARNING,
                     "SYS_NOTICE": logging.info,
                     "SYS_INFO": logging.INFO,
                     "SYS_DEBUG": logging.DEBUG
                     }
        self._log_level = log_level[config.get("LOGGING", "log_level")]

    def work(self):
        while True:
            self._logger.info("scheduled job is at %s\
            " % str(self._scheduler.scheduled_job))
            self._logger.info("send statistics frequency is %s\
            " % str(self._scheduler.send_freq))
            if not self._scheduler.is_job:
                self._logger.info("There is no job now. Exiting... ")
                sleep(3600)
                continue
            self._logger.info("There is job now.")
            self._vnc_api_client = init_vnc_api_client()
            self._stats = Stats(client=self._vnc_api_client)
            self._stats_server = getenv('STATS_SERVER')
            self._server_resp = self._send_stats(
                    stats=self._stats,
                    stats_server=self._stats_server)
            self._logger.info("Sending result %s" % str(self._server_resp))
            self._scheduler.job_is_done()
            sleep(3600)

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
            req = Request(url=stats_server,
                          data=json.dumps(stats.__dict__),
                          headers={'Content-Type': 'application/json'})
            response = urlopen(url=req)
            resp_code = response.code
            self._logger.debug(str("The server response code %s" % resp_code))
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
            self._logger.debug("response code: %s" % str(e.code))
        except URLError as e:
            server_resp["message"] = str(e.reason[1])
            self._logger.debug("error number: %s" % str(e.reason[0]))
        except Exception as e:
            server_resp["message"] = "Unable to send metrics (Unknown error).\
Traceback: %s" % str(format_exc())
        finally:
            self._logger.debug("stats: %s" % (str(stats)))
        return server_resp


def main():
    postman = Postman()
    postman.work()
