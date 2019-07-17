#!/bin/bash

source /common.sh

if [[ ! -d /host/usr/bin ]]; then
  echo "ERROR: there is no mount /host/usr/bin from Host's /usr/bin. Utility vrouter-agent-debug-tool could not be created."
  exit 1
fi

if [[ -z "$CONTRAIL_TOOLS_IMAGE" ]]; then
  echo 'ERROR: variable $CONTRAIL_TOOLS_IMAGE is not defined. Utility vrouter-agent-debug-tool could not be created.'
  exit 1
fi

tmp_file=/host/usr/bin/vrouter-agent-debug-tool.tmp
cat > $tmp_file << EOM
#!/usr/bin/python                                                                           
"""         
Synopsis:
    Collect logs, gcore(optional), introspect logs, sandesh traces and
    docker logs from vrouter node.                                                          
    Collect logs specific to control node.                                                  
Usage:      
    python vrouter_agent_debug_info.py -i <input_file>                                      
Options:                                                                                    
    -h, --help          Display this help information.                                      
    -i                  Input file which has vrouter and control node details.              
                        This file should be a yaml file.                                    
                        Sepcify deployment_method from one of these: 'rhosp_director'/'ansible'/'kubernetes'
                        Specify vim from one of these: 'rhosp'/'openstack'/'kubernetes'     
                        Specify gcore_needed as true if you want to collect gcore.          
                        Template and a sample input_file is shown below.                    
                        You need to mention ip, ssh_user and ssh_pwd/ssh_key_file           
                        required to login to vrouter/control node.                          
                        You can add multiple vrouter or control node details.               
                                                                                            
Template for input file:
------------------------                                                                    
provider_config:                                                                            
  deployment_method: 'rhosp_director'/'ansible'/'kubernetes'                                
  vim: 'rhosp'/'openstack'/'kubernetes'
  vrouter:
    node1
      ip: <ip-address>
      ssh_user: <username>
      ssh_pwd: <password>                                                                   
      ssh_key_file: <ssh key file>
    node2:
    .
    .
    .
    noden:
  control:
    node1 
      ip: <ip-address>
      ssh_user: <username>                                                                  
      ssh_pwd: <password>                                                                   
      ssh_key_file: <ssh key file>                                                          
    node2:
    .
    .
    .
    noden:
  gcore_needed: <true/false>

sample_input.yaml
-----------------
provider_config:
  # deployment_method: 'rhosp'/'openstack'/'kubernetes'
  deployment_method: 'rhosp'
  vrouter:
    node1:
      ip: 192.168.24.7
      ssh_user: heat-admin
      # if deployment_method is rhosp then ssh_key_file is mandatory
      ssh_key_file: '/home/stack/.ssh/id_rsa'
    node2:
      ip: 192.168.24.8
      ssh_user: heat-admin
      # if deployment_method is rhosp then ssh_key_file is mandatory
      ssh_key_file: '/home/stack/.ssh/id_rsa'
  control:
    node1:
      ip: 192.168.24.6
      ssh_user: heat-admin
      ssh_key_file: '/home/stack/.ssh/id_rsa'
    node2:
      ip: 192.168.24.23
      ssh_user: heat-admin
      ssh_key_file: '/home/stack/.ssh/id_rsa'
  gcore_needed: true
"""

import subprocess
import sys
import os
import yaml

USAGE_TEXT = __doc__

def usage():
    print USAGE_TEXT
    sys.exit(1)
# end usage

def parse_yaml_file(file_path):
    with open(file_path) as stream:
        try:
            yaml_data = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print('Error[%s] while parsing file %s' % (exc, file_path))
            return None
        else:
            return yaml_data
# end parse_yaml_file

def get_ssh_key_file(data):
    ssh_key_file = None
    for item in data['provider_config']['vrouter']:
        ssh_key_file = data['provider_config']['vrouter'][item].get('ssh_key_file')
    print ssh_key_file
    return ssh_key_file


def main():
    argv = sys.argv[1:]
    try:
        input_file = argv[argv.index('-i') + 1]
    except ValueError:
        usage()
        return
    input_file = os.path.realpath(input_file)
    yaml_data = parse_yaml_file(input_file)
    if yaml_data is None:
        print('Error parsing yaml file. Exiting!!!')
    ssh_key_file = get_ssh_key_file(yaml_data)
    if ssh_key_file:
        ssh_key_file = os.path.realpath(ssh_key_file)
        cmd = 'docker run --rm --name contrail-tools -v %s:/root/.ssh/id_rsa -v %s:/root/input.yaml --pid host --net host --privileged $CONTRAIL_TOOLS_IMAGE'%(ssh_key_file, input_file)
    else:
        cmd = 'docker run --rm --name contrail-tools -v %s:/root/input.yaml --pid host --net host --privileged $CONTRAIL_TOOLS_IMAGE'%(input_file)
    print cmd
    subprocess.call(cmd, shell=True)
# end main

if __name__ == '__main__':
    main()
EOM
chmod 755 $tmp_file
mv -f $tmp_file /usr/bin/vrouter-agent-debug-tool
