# Post-init container for configuring Contrail after Cloud is up.

Contrail requires provisioning when all services are up. It can done like this:

docker run -it --network host IMAGE_ID \
  /opt/contrail/utils/provision_database_node.py --oper add --host_name ip-192-168-130-83.us-west-2.compute.internal --host_ip 192.168.130.83 \
  --api_server_ip 192.168.130.83 --api_server_port 8082 --admin_password PASSWORD --admin_tenant_name admin --admin_user admin


Also it can be used for getting some status:

docker run -it --network host IMAGE_ID contrail-status
