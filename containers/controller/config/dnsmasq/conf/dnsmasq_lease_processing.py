#!/usr/bin/python

import logging
import os
import sys

from vnc_api.vnc_api import VncApi
from vnc_api.gen.resource_client import PhysicalRouter

DEFAULT_LOG_PATH = '/var/log/contrail/dnsmasq.log'
LOGGING_FORMAT = \
    '%(asctime)s.%(msecs)03d %(name)s [%(levelname)s]:  %(message)s'
DATE_FORMAT = "%m/%d/%Y %H:%M:%S"

vnc_api = VncApi(username=os.environ['KEYSTONE_AUTH_ADMIN_USER'],
             password=os.environ['KEYSTONE_AUTH_ADMIN_PASSWORD'],
             tenant_name=os.environ['KEYSTONE_AUTH_ADMIN_TENANT'],
             api_server_host=(os.environ['CONTROLLER_NODES']).split(','))

def main():
    logging.basicConfig(
        filename=DEFAULT_LOG_PATH,
        level=logging.INFO,
        format=LOGGING_FORMAT,
        datefmt=DATE_FORMAT)
    logger = logging.getLogger("dnsmasq")
    logger.setLevel(logging.INFO)

    if sys.argv[1] == 'read':
        # read from DB mac:ip
        mac_ip = []
        filters = {}
        lease = 0
        filters['physical_router_managed_state'] = "dhcp"
        for pr in vnc_api.physical_routers_list(filters=filters).get(
                'physical-routers'):
            device_obj = vnc_api.physical_router_read(
                id=pr.get('uuid'), fields=['physical_router_management_mac',
                                           'physical_router_management_ip',
                                           'physical_router_dhcp_parameters']
            )
            if device_obj.get_physical_router_dhcp_parameters():
                lease=device_obj.get_physical_router_dhcp_parameters().lease_expiry_time

            print("DNSMASQ_LEASE=%s %s %s * *" % (
                lease,
                device_obj.get_physical_router_management_mac(),
                device_obj.get_physical_router_management_ip()))
            logger.info("DNSMASQ_LEASE=%s %s %s * *" % (
                lease,
                device_obj.get_physical_router_management_mac(),
                device_obj.get_physical_router_management_ip()))
    elif sys.argv[1] == 'write':
        # write to the DB dummy PR with mac:ip
        fq_name = ['default-global-system-config', sys.argv[3]]
        physicalrouter = PhysicalRouter(
            parent_type='global-system-config',
            fq_name=fq_name,
            physical_router_management_mac=sys.argv[2],
            physical_router_management_ip=sys.argv[3],
            physical_router_managed_state='dhcp',
            physical_router_hostname=sys.argv[4],
            physical_router_dhcp_parameters={
                'lease_expiry_time': sys.argv[5]
            }
        )
        try:
            pr_uuid = vnc_api.physical_router_create(physicalrouter)
        except Exception:
            logger.info(
                "Router '%s' already exists, hence updating it" % fq_name[-1]
            )
            pr_uuid = vnc_api.physical_router_update(physicalrouter)

        logger.info("DNSMASQ_LEASE_OBTAINED=%s %s %s" % (sys.argv[4],
                                                         sys.argv[2],
                                                         sys.argv[3]))
        logger.info("Router created id: %s" % pr_uuid)
    elif sys.argv[1] == 'delete':
        fq_name = ['default-global-system-config', sys.argv[2]]
        try:
            vnc_api.physical_router_delete(fq_name=fq_name)
        except Exception:
            logger.info("Router '%s' doesnot exist" % fq_name[-1])
if __name__ == '__main__':
    main()
