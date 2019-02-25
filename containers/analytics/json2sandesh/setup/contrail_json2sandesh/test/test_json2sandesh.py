import unittest

from pysandesh.sandesh_base import Sandesh
from contrail_json2sandesh.converter import Converter
from cfgm_common.uve.vnc_api.ttypes import ContrailConfig,\
                                           VncApiStats,\
                                           VncApiCommon,\
                                           FabricJobExecution,\
                                           PhysicalRouterJobExecution,\
                                           VncApiLatencyStats,\
                                           VncApiDebug,\
                                           VncApiInfo,\
                                           VncApiNotice,\
                                           VncApiError
from cfgm_common.uve.cfgm_cpuinfo.ttypes import ModuleCpuState


class Json2sandeshTestCase(unittest.TestCase):
    def setUp(self):
        self.sandesh = Sandesh()
        self.logger = self.sandesh._init_logger(module="contrail-api")
        self.converter = Converter(sandesh=self.sandesh)

    def tearDown(self):
        pass


class ContrailConfigTraceValidTestCase(Json2sandeshTestCase):
    def runTest(self):
        valid_data = {
            "table": "ObjectVNTable",
            "name": "default-domain:default-project:Mitya20",
            "elements": {
                "fq_name": ["default -domain ",
                            "default -project ",
                            "Mitya20"],
                "virtual_network_network_id": 19,
                "parent_uuid": "e5a88a7a-5c9e-453e-a780-d7dfa97ed794",
                "parent_type": "project",
                "perms2": {
                    "owner": "cloud-admin",
                    "owner_access": 7,
                    "global_access": 0,
                    "share": []
                },
                "id_perms": {
                    "enable": "true",
                    "uuid": {
                        "uuid_mslong": 5262224048337731646,
                        "uuid_lslong": 12146983599913831512
                    },
                    "created": "2019-01-25T16:56:33.100369",
                    "description": "null",
                    "creator": "null",
                    "user_visible": "true",
                    "last_modified": "2019-01-25T16:56:33.100369",
                    "permissions": {
                        "owner": "cloud-admin",
                        "owner_access": 7,
                        "other_access": 7,
                        "group": "cloud-admin-group",
                        "group_access": 7
                    }
                },
                "display_name": "Mitya20",
                "network_ipam_refs": [{
                    "to": ["default-domain",
                           "default-project",
                           "default-network-ipam"],
                    "attr": {
                        "ipam_subnets": [{
                            "subnet_uuid":
                                "543e5592-a494-4f6a-9b12-1ec4f6488b84",
                            "subnet": {
                                "ip_prefix": "1.1.1.0",
                                "ip_prefix_len": 24
                            },
                            "dns_server_address": "1.1.1.253",
                            "default_gateway": "1.1.1.254"
                        }]
                    }
                }],
                "uuid": "49072ce4-39b0-403e-a892-c13a055c0c58"
            },
            "deleted": "false"
        }

        result = self.converter.verify_data(
            checked_class=ContrailConfig(),
            raw_sandesh_data=valid_data)
        self.assertFalse(result["error"])


class VncApiStatsLogValidTestCase(Json2sandeshTestCase):
    def runTest(self):
        valid_data = {
            "operation_type": "PUT",
            "user": "",
            "useragent": "eremeev.progmaticlab.com:/usr/bin/contrail-schema",
            "remote_ip": "192.168.30.133",
            "domain_name": "default-domain",
            "project_name": "default-project",
            "object_type": "access_control_list",
            "response_time_in_usec": 32723,
            "response_size": 168,
            "resp_code": "200",
            "req_id": ""
        }

        result = self.converter.verify_data(
            checked_class=VncApiStats(),
            raw_sandesh_data=valid_data)
        self.assertFalse(result["error"])


class VncApiConfigLogValidTestCase(Json2sandeshTestCase):
    def runTest(self):
        valid_data = {
            "identifier_uuid": "99c36c1e-20c7-4b92-accf-2cc7b75f0f9b",
            "object_type": "project",
            "identifier_name": "default-domain:k8s-default",
            "url": "http://127.0.0.1/ref-update",
            "operation": "ref-update",
            "useragent": "",
            "remote_ip": "",
            "params": "",
            "body": "",
            "domain": "default-domain",
            "project": "",
            "user": "",
            "error": ""
        }

        result = self.converter.verify_data(
            checked_class=VncApiCommon(),
            raw_sandesh_data=valid_data)
        self.assertFalse(result["error"])


class FabricJobUveValidTestCase(Json2sandeshTestCase):
    def runTest(self):
        valid_data = {
            "name": "Mitya",
            "execution_id": "Mitya",
            "deleted": "false",
            "job_start_ts": 133,
            "percentage_completed": "13",
            "job_status": "Mitya",
            "table": "ObjectJobExecutionTable"
        }

        result = self.converter.verify_data(
            checked_class=FabricJobExecution(),
            raw_sandesh_data=valid_data)
        self.assertFalse(result["error"])


class PhysicalRouterJobUveValidTestCase(Json2sandeshTestCase):
    def runTest(self):
        valid_data = {
            "name": "Mitya",
            "execution_id": "Mitya",
            "deleted": "false",
            "job_start_ts": 100,
            "prouter_state": "",
            "percentage_completed": "13",
            "job_status": "Mitya",
            "device_op_results": "Mitya",
            "table": "ObjectJobExecutionTable"
        }

        result = self.converter.verify_data(
            checked_class=PhysicalRouterJobExecution(),
            raw_sandesh_data=valid_data)
        self.assertFalse(result["error"])


class ModuleCpuStateTraceValidTestCase(Json2sandeshTestCase):
    def runTest(self):
        valid_data = {
            "name": "node-10-15-42-193.localdomain",
            "deleted": "false",
            "build_info": {
                "build-info": [{
                    "build-version": "5.1.0",
                    "build-time": "2019-02-05 02:35:53.412274",
                    "build-user": "zuul",
                    "build-hostname":
                        "centos-7-4-builder-juniper-contrail-ci-0000181197",
                    "build-id": "5.1.0-504.el7",
                    "build-number": "@contrail"
                }]
            },
            "config_node_ip": ["10.15.42.193", "172.17.0.1"],
            "table": "ObjectConfigNode"
        }

        result = self.converter.verify_data(
            checked_class=ModuleCpuState(),
            raw_sandesh_data=valid_data)
        self.assertFalse(result["error"])


class VncApiLatencyStatsLogValidTestCase(Json2sandeshTestCase):
    def runTest(self):
        valid_data = {
            "operation_type": "SEND",
            "application": "CASSANDRA",
            "response_time_in_usec": 4240,
            "response_size": 0,
            "identifier": "req-d214aafc-1efc-470e-a110-edd582210807",
            "node_name": "issu-vm6"
        }

        result = self.converter.verify_data(
            checked_class=VncApiLatencyStats(),
            raw_sandesh_data=valid_data)
        self.assertFalse(result["error"])


class VncApiDebugValidTestCase(Json2sandeshTestCase):
    def runTest(self):
        valid_data = {
            "api_msg": "Mitya"
        }

        result = self.converter.verify_data(
            checked_class=VncApiDebug(),
            raw_sandesh_data=valid_data)
        self.assertFalse(result["error"])


class VncApiNoticeValidTestCase(Json2sandeshTestCase):
    def runTest(self):
        valid_data = {
            "api_msg": "Mitya"
        }

        result = self.converter.verify_data(
            checked_class=VncApiNotice(),
            raw_sandesh_data=valid_data)
        self.assertFalse(result["error"])


class VncApiInfoValidTestCase(Json2sandeshTestCase):
    def runTest(self):
        valid_data = {
            "api_msg": "Mitya"
        }

        result = self.converter.verify_data(
            checked_class=VncApiInfo(),
            raw_sandesh_data=valid_data)
        self.assertFalse(result["error"])


class VncApiErrorValidTestCase(Json2sandeshTestCase):
    def runTest(self):
        valid_data = {
            "api_msg": "Mitya"
        }

        result = self.converter.verify_data(
            checked_class=VncApiError(),
            raw_sandesh_data=valid_data)
        self.assertFalse(result["error"])


if __name__ == "__main__":
    unittest.main()
