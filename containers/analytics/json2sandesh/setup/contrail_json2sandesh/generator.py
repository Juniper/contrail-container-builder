from gevent import monkey
monkey.patch_all()
from gevent import spawn, joinall
from time import sleep
from socket import gethostname

from pysandesh.sandesh_base import  Sandesh, SandeshConfig
from cfgm_common.vnc_greenlets import VncGreenlet
from converter import Converter


class Generator(object):
    def __init__(self, generator_config):
        self._sandesh = Sandesh()
        self._converter = Converter(self._sandesh)
        self._sandesh_config = SandeshConfig(
            system_logs_rate_limit=generator_config["sandesh_send_rate_limit"])
        self._sandesh.init_generator(
            module="contrail-api",
            source=gethostname(),
            node_type="Config",
            instance_id=generator_config["instance_id"],
            collectors=generator_config["collectors"],
            client_context="json2sandesh_context",
            http_port=int("-1"),
            sandesh_req_uve_pkg_list=["cfgm_common"],
            connect_to_collector=True,
            logger_class=None,
            logger_config_file=None,
            host_ip="127.0.0.1",
            alarm_ack_callback=None,
            config=self._sandesh_config)

        self._sandesh.set_logging_params(
            enable_local_log=True,
            category=None,
            level=generator_config["level"],
            file=generator_config["file"],
            enable_syslog=None,
            syslog_facility=None,
            enable_trace_print=None,
            enable_flow_log=None)

        VncGreenlet.register_sandesh_handler()
        self._client = self._sandesh.client()
        self.logger.info("sandesh client is %s" % self._client)
        self._connection = self._client.connection()
        self.logger.info(
            "sandesh connection is %s" % self._connection)
        self._con_state = self._connection.state()
        self.logger.info(
            "sandesh client connection state is %s" % self.con_state)

    @property
    def logger(self):
        return self._sandesh.logger()

    @property
    def con_state(self):
        return self._connection.state()

    def connect(self):
        while self.con_state is not "Established":
            self.logger.info("connection state is %s" % self.con_state)
            sleep(1)

    def send_trace(self, raw_payload):
        sandesh_type = raw_payload['sandesh_type']
        converting = self._converter.convert(sandesh_type,
                                             raw_payload['payload'])
        if not converting["error"]:
            trace = converting["trace"]
            self.logger.info("trace is %s" % trace)
            send_task = spawn(
                converting["send_method"], trace, sandesh=self._sandesh)
            joinall([send_task],)
            value = send_task.value
            self.logger.info(
                "send method return code is %s" % value)
            exception = send_task.exception
            self.logger.info(
                "exception in send method is %s" % exception)
            return {'send_method_return_code': value,
                    'send_method_exception': exception}
        else:
            self.logger.error(converting["error"])
            return {"error": converting["error"]}
