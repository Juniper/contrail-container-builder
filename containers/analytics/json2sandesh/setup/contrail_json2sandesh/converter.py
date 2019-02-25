from traceback import format_exc

from cfgm_common.uve.vnc_api.ttypes import ContrailConfig,\
                                           ContrailConfigTrace,\
                                           VncApiStatsLog,\
                                           VncApiStats, \
                                           VncApiConfigLog, \
                                           VncApiCommon, \
                                           FabricJobExecution, \
                                           FabricJobUve, \
                                           PhysicalRouterJobUve, \
                                           PhysicalRouterJobExecution, \
                                           VncApiLatencyStatsLog, \
                                           VncApiLatencyStats, \
                                           VncApiDebug, \
                                           VncApiInfo, \
                                           VncApiNotice, \
                                           VncApiError
from cfgm_common.uve.cfgm_cpuinfo.ttypes import ModuleCpuStateTrace, \
                                                ModuleCpuState

from pysandesh.Thrift import TType


class Converter(object):
    def __init__(self, sandesh):
        self._thrift = {
            "BOOL": bool,
            "BYTE": int,
            "I16": int,
            "I32": int,
            "I64": int,
            "DOUBLE": float,
            "STRING": str,
            "LIST": list,
            "U64": int,
            "MAP": self.thrift_dict}

# classes are arranged in specific order to initialize objects and insert them
# in the next class instance.
# args stand for arguments for last class in list
# args are arranged:
# 1st - instance of previous class or main trace data
# 2nd - sandesh
# others - additional arguments
        self._converters_map = {
            "ContrailConfigTrace": {
                "sandesh_classes": [ContrailConfig,
                                    ContrailConfigTrace],
                "args": ["data", "sandesh", "table"]},
            "VncApiStatsLog": {
                "sandesh_classes": [VncApiStats,
                                    VncApiStatsLog],
                "args": ["api_stats", "sandesh"]},
            "VncApiConfigLog": {
                "sandesh_classes": [VncApiCommon,
                                    VncApiConfigLog],
                "args": ["api_log", "sandesh"]},
            "FabricJobUve":
                {"sandesh_classes": [FabricJobExecution,
                                     FabricJobUve],
                 "args": ["data", "sandesh", "table"]},
            "PhysicalRouterJobUve":
                {"sandesh_classes": [PhysicalRouterJobExecution,
                                     PhysicalRouterJobUve],
                 "args": ["data", "sandesh", "table"]},
            "ModuleCpuStateTrace":
                {"sandesh_classes": [ModuleCpuState,
                                     ModuleCpuStateTrace],
                 "args": ["data", "sandesh", "table"]},
            "VncApiLatencyStatsLog":
                {"sandesh_classes": [VncApiLatencyStats,
                                     VncApiLatencyStatsLog],
                 "args": ["api_latency_stats", "sandesh", "node_name"]},
            "VncApiDebug":
                {"sandesh_classes": [VncApiDebug],
                 "args": ["api_msg", "sandesh"]},
            "VncApiInfo":
                {"sandesh_classes": [VncApiInfo],
                 "args": ["api_msg", "sandesh"]},
            "VncApiNotice":
                {"sandesh_classes": [VncApiNotice],
                 "args": ["api_msg", "sandesh"]},
            "VncApiError":
                {"sandesh_classes": [VncApiError],
                 "args": ["api_msg", "sandesh"]},
                 }

        self._sandesh = sandesh
        self._logger = self._sandesh.logger()

    @property
    def logger(self):
        return self._sandesh.logger()

    def thrift_dict(self, attr_data):
        thrift_dict = dict(attr_data)
        return {key: str(thrift_dict[key]) for key in thrift_dict}

    def convert(self, sandesh_type, raw_sandesh_data):
        error = ""
        trace = None
        send_method = None

        sandesh_classes = self._converters_map[sandesh_type]["sandesh_classes"]
        self.logger.debug("sandesh classes %s" % str(sandesh_classes))
        try:
            result = self.verify_data(sandesh_classes[0],
                                      raw_sandesh_data)
            if result["error"]:
                return {"trace": trace,
                        "send_method": send_method,
                        "error": result["error"]}
            checked_data = result["data"]
            args = self._converters_map[sandesh_type]["args"]
            kwargs = dict()
            kwargs[args[1]] = self._sandesh
            if len(sandesh_classes) > 1:
                sandesh_data = sandesh_classes[0](**checked_data)
                kwargs[args[0]] = sandesh_data
                if len(args) > 2:
                    for arg in args[2:]:
                        kwargs[arg] = raw_sandesh_data[arg]
            else:
                kwargs[args[0]] = checked_data[args[0]]
            self.logger.debug("trace args %s" % str(kwargs))
            trace = sandesh_classes[-1](**kwargs)
            send_method = getattr(sandesh_classes[-1], "send")
        except KeyError:
            error = "json field '%s' was not provided" % str(arg)
            self.logger.error(error)
        except:
            error = format_exc()
        return {"trace": trace, "send_method": send_method, "error": error}

    def verify_data(self, checked_class, raw_sandesh_data):
        try:
            error = str()
            self.logger.debug("checked class %s" % str(checked_class))
            self.logger.debug("raw sandesh data %s" % str(raw_sandesh_data))
            thrift_format = checked_class.thrift_spec
            data = dict()

            if thrift_format is not None:
                for thrift_field in thrift_format:
                    self.logger.debug("thrift_field %s" % str(thrift_field))
                    if thrift_field is not None:
                        thrift_type = TType._VALUES_TO_NAMES[thrift_field[1]]
                        self.logger.debug("thrift_type %s" % str(
                            thrift_type))
                        convert_method = self._thrift[thrift_type]
                        self.logger.debug("convert_method %s" % str(
                            convert_method))
                        attr_name = thrift_field[2]
                        self.logger.debug("attr name %s" % str(attr_name))
                        data[attr_name] = convert_method(
                            raw_sandesh_data[attr_name])
                        self.logger.debug("data[attr] %s" % str(
                            data[attr_name]))
            else:
                data = raw_sandesh_data
        except KeyError:
            error = "json field '%s' was not provided" % str(thrift_field)
            data = None
            self.logger.error(error)
        return {"data": data, "error": error}
