from bottle import route, request, response, run, install
from traceback import format_exc
from functools import wraps
from datetime import datetime
from socket import error as socket_error
from simplejson import JSONDecodeError


class ApiServer(object):
    def __init__(self, generator):
        self._generator = generator
        self.logger = generator.logger
        install(self.logging)
        route('/', "GET", self.test_route)
        route('/json2sandesh', "POST", self.parse_json)

    @property
    def generator(self):
        return self._generator

    def logging(self, fn):
        @wraps(fn)
        def _logging(*args, **kwargs):
            actual_response = fn(*args, **kwargs)
            self.logger.warning("%s request %s" % (datetime.now(), request))
            self.logger.warning("%s response %s" % (datetime.now(), response))
            return actual_response
        return _logging

    def run(self, interface_config):
        try:
            run(**interface_config)
        except socket_error:
            self.logger.error("Api host or port are already used."
                              " Please change it.")

    def test_route(self):
        return {"api_version": "0.5"}

    def parse_json(self):
        try:
            raw_payload = request.json
            sandesh_type = raw_payload["sandesh_type"]
            response = self._generator.send_trace(raw_payload)
        except JSONDecodeError as e:
            sandesh_type = "Unknown"
            response = "request %s. request body is not valid json: %s" % (str(
                request),
                str(e))
            self.logger.error(response)
        except:
            response = format_exc()
            self.logger.error(str(response))
        return {"sandesh_type": sandesh_type, "response": response}
