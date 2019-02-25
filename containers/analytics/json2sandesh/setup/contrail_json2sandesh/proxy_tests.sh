#!/usr/bin/bash

URL="http://192.168.30.133:8113/json2sandesh"

# test url
# URL="http://192.168.30.133:8115/json2sandesh"

# ContrailConfigTrace
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -d '{
	"sandesh_type": "ContrailConfigTrace",
	"payload": {
		"table": "ObjectVNTable",
		"name": "default-domain:default-project:Mitya20",
		"elements": {
			"fq_name": ["default -domain ", "default -project ", "Mitya20"],
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
				"enable": true,
				"uuid": {
					"uuid_mslong": 5262224048337731646,
					"uuid_lslong": 12146983599913831512
				},
				"created": "2019-01-25T16:56:33.100369",
				"description": null,
				"creator": null,
				"user_visible": true,
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
				"to": ["default-domain", "default-project", "default-network-ipam"],
				"attr": {
					"ipam_subnets": [{
						"subnet_uuid": "543e5592-a494-4f6a-9b12-1ec4f6488b84",
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
		"deleted": false
	}
}' $URL

# VncApiStatsLog
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -d '{
	"sandesh_type": "VncApiStatsLog",
	"payload": {
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
}' $URL

# VncApiConfigLog
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -d '{
	"sandesh_type": "VncApiConfigLog",
	"payload": {
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
}' $URL

# FabricJobUve
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -d '{
	"sandesh_type": "FabricJobUve",
	"payload": {
		"name": "Mitya",
	    "execution_id": "Mitya",
	    "deleted": false,
	    "job_start_ts": 133,
	    "percentage_completed": "13",
	    "job_status": "Mitya",
	    "table": "ObjectJobExecutionTable"
	}
}' $URL


# PhysicalRouterJobUve
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -d '{
	"sandesh_type": "PhysicalRouterJobUve",
	"payload": {
		"name": "Mitya",
		"execution_id": "Mitya",
		"deleted": false,
		"job_start_ts": 100,
		"prouter_state": "",
		"percentage_completed": "13",
		"job_status": "Mitya",
		"device_op_results": "Mitya",
		"table": "ObjectJobExecutionTable"
	}
}' $URL

# ModuleCpuStateTrace
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -d '{
	"sandesh_type": "ModuleCpuStateTrace",
	"payload": {
		"name": "node-10-15-42-193.localdomain",
		"deleted": false,
		"build_info": {
			"build-info": [{
				"build-version": "5.1.0",
				"build-time": "2019-02-05 02:35:53.412274",
				"build-user": "zuul",
				"build-hostname": "centos-7-4-builder-juniper-contrail-ci-0000181197",
				"build-id": "5.1.0-504.el7",
				"build-number": "@contrail"
			}]
		},
		"config_node_ip": ["10.15.42.193", "172.17.0.1"],
		"table": "ObjectConfigNode"
	}
}' $URL

# VncApiLatencyStatsLog
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -d '{
	"sandesh_type": "VncApiLatencyStatsLog",
	"payload": {
			"operation_type": "SEND",
			"application": "CASSANDRA",
			"response_time_in_usec": 4240,
			"response_size": 0,
			"identifier": "req-d214aafc-1efc-470e-a110-edd582210807",
			"node_name": "issu-vm6"
	}
}' $URL

# VncApiDebug
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -d '{
	"sandesh_type": "VncApiDebug",
	"payload": {
			"api_msg": "Mitya"
	}
}' $URL

# VncApiNotice
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -d '{
	"sandesh_type": "VncApiNotice",
	"payload": {
			"api_msg": "Mitya"
	}
}' $URL

# VncApiInfo
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -d '{
	"sandesh_type": "VncApiInfo",
	"payload": {
			"api_msg": "Mitya"
	}
}' $URL

# VncApiError
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -d '{
	"sandesh_type": "VncApiError",
	"payload": {
			"api_msg": "Mitya"
	}
}' $URL
