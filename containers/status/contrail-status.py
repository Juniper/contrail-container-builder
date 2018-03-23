#! /usr/bin/python
#
# Copyright (c) 2014 Juniper Networks, Inc. All rights reserved.
#

from optparse import OptionParser
import subprocess
import os
import glob
import platform
import ConfigParser
import socket
import re
import requests
import warnings
import docker
try:
    from requests.packages.urllib3.exceptions import SubjectAltNameWarning
    warnings.filterwarnings('ignore', category=SubjectAltNameWarning)
except:
    try:
        from urllib3.exceptions import SubjectAltNameWarning
        warnings.filterwarnings('ignore', category=SubjectAltNameWarning)
    except:
        pass
warnings.filterwarnings('ignore', ".*SNIMissingWarning.*")
warnings.filterwarnings('ignore', ".*InsecurePlatformWarning.*")
warnings.filterwarnings('ignore', ".*SubjectAltNameWarning.*")
from StringIO import StringIO
from lxml import etree
from sandesh_common.vns.constants import ServiceHttpPortMap, \
    NodeUVEImplementedServices, ServicesDefaultConfigurationFiles, \
    BackupImplementedServices
from distutils.version import LooseVersion

DPDK_NETLINK_TCP_PORT = 20914

CONTRAIL_SERVICES = {'vrouter' : {'nodemgr' : 'contrail-vrouter-nodemgr',
                                   'agent' : 'contrail-vrouter-agent'},
                     'control' : {'nodemgr' : 'contrail-control-nodemgr',
                                  'control' : 'contrail-control',
                                  'named' : 'contrail-named',
                                  'dns' : 'contrail-dns'},
                     'config' : {'nodemgr' : 'contrail-config-nodemgr',
                                 'api' : 'contrail-api',
                                 'schema' : 'contrail-schema',
                                 'svc-monitor' : 'contrail-svc-monitor',
                                 'device-manager' : 'contrail-device-manager'},
                     'config-database' : ['cassandra',
                                          'zookeeper',
                                          'rabbitmq'],
                     'analytics' : {'nodemgr' : 'contrail-analytics-nodemgr',
                                    'api' : 'contrail-analytics-api',
                                    'collector' : 'contrail-collector',
                                    'query-engine' : 'contrail-query-engine',
                                    'alarm-gen' : 'contrail-alarm-gen',
                                    'snmp-collector' : 'contrail-snmp-collector',
                                    'topology' : 'contrail-topology'},
                     'analytics-database' : ['cassandra',
                                             'zookeeper',
                                             'kafka'],
                     'webui' : ['web',
                                'job',
                                'redis'],
                     'kubernetes' : {'kube-manager': 'contrail-kube-manager'},
                    }

# define labels
CONTRAIL_POD_LABEL = "net.juniper.contrail.pod"
CONTRAIL_SVC_LABEL = "net.juniper.contrail.service"
K8S_CONTAINER_NAME_LABEL = "io.kubernetes.container.name"

# TODO: Include vcenter-plugin

(distribution, os_version, os_id) = \
    platform.linux_distribution(full_distribution_name=0)
distribution = distribution.lower()

class EtreeToDict(object):
    """Converts the xml etree to dictionary/list of dictionary."""

    def __init__(self, xpath):
        self.xpath = xpath
    #end __init__

    def _handle_list(self, elems):
        """Handles the list object in etree."""
        a_list = []
        for elem in elems.getchildren():
            rval = self._get_one(elem, a_list)
            if 'element' in rval.keys():
                a_list.append(rval['element'])
            elif 'list' in rval.keys():
                a_list.append(rval['list'])
            else:
                a_list.append(rval)

        if not a_list:
            return None
        return a_list
    #end _handle_list

    def _get_one(self, xp, a_list=None):
        """Recrusively looks for the entry in etree and converts to dictionary.

        Returns a dictionary.
        """
        val = {}

        child = xp.getchildren()
        if not child:
            val.update({xp.tag: xp.text})
            return val

        for elem in child:
            if elem.tag == 'list':
                val.update({xp.tag: self._handle_list(elem)})
            else:
                rval = self._get_one(elem, a_list)
                if elem.tag in rval.keys():
                    val.update({elem.tag: rval[elem.tag]})
                else:
                    val.update({elem.tag: rval})
        return val
    #end _get_one

    def get_all_entry(self, path):
        """All entries in the etree is converted to the dictionary

        Returns the list of dictionary/didctionary.
        """
        xps = path.xpath(self.xpath)

        if type(xps) is not list:
            return self._get_one(xps)

        val = []
        for xp in xps:
            val.append(self._get_one(xp))
        return val
    #end get_all_entry

    def find_entry(self, path, match):
        """Looks for a particular entry in the etree.
        Returns the element looked for/None.
        """
        xp = path.xpath(self.xpath)
        f = filter(lambda x: x.text == match, xp)
        if len(f):
            return f[0].text
        return None
    #end find_entry

#end class EtreeToDict

class IntrospectUtil(object):
# TODO: restore certs logic
#    def __init__(self, ip, port, debug, timeout, keyfile, certfile, cacert):
    def __init__(self, ip, port, debug, timeout):
        self._ip = ip
        self._port = port
        self._debug = debug
        self._timeout = timeout
# TODO: restore certs logic
#        self._certfile = certfile
#        self._keyfile = keyfile
#        self._cacert = cacert
    #end __init__

    def _mk_url_str(self, path, secure=False):
        if secure:
            return "https://%s:%d/%s" % (self._ip, self._port, path)
        return "http://%s:%d/%s" % (self._ip, self._port, path)
    #end _mk_url_str

    def _load(self, path):
        url = self._mk_url_str(path)
        try:
            resp = requests.get(url, timeout=self._timeout)
        except requests.ConnectionError:
            url = self._mk_url_str(path, True)
            resp = requests.get(url, timeout=self._timeout)
# TODO: restore certs logic
#            resp = requests.get(url, timeout=self._timeout, verify=\
#                    self._cacert, cert=(self._certfile, self._keyfile))
        if resp.status_code == requests.codes.ok:
            return etree.fromstring(resp.text)
        else:
            if self._debug:
                print 'URL: %s : HTTP error: %s' % (url, str(resp.status_code))
            return None

    #end _load

    def get_uve(self, tname):
        path = 'Snh_SandeshUVECacheReq?x=%s' % (tname)
        xpath = './/' + tname
        p = self._load(path)
        if p is not None:
            return EtreeToDict(xpath).get_all_entry(p)
        else:
            if self._debug:
                print 'UVE: %s : not found' % (path)
            return None
    #end get_uve

#end class IntrospectUtil

def get_http_server_port_from_cmdline_options(svc_name, debug):
    name, instance = svc_name, None
    name_instance = svc_name.rsplit(':', 1)
    if len(name_instance) == 1:
        # Try if it is systemd templated service
        name_instance = svc_name.rsplit('@', 1)
    if len(name_instance) == 2:
        name, instance = name_instance

    cmd = 'ps -eaf | grep %s | grep http_server_port' % (name)
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    cmdout = p.communicate()[0]
    processes = cmdout.splitlines()
    for p in processes:
        p = p.split()
        try:
            if instance:
                wi = p.index('--worker_id')
                if instance == p[wi+1]:
                    pi = p.index('--http_server_port')
                    return int(p[pi+1])
            else:
                pi = p.index('--http_server_port')
                return int(p[pi+1])
        except ValueError:
            continue
    return -1
# end get_http_server_port_from_cmdline_options

def _get_http_server_port_from_conf(svc_name, conf_file, debug):
    try:
        fp = open(conf_file)
    except IOError as e:
        if debug:
            print '{0}: Could not read filename {1}'.format(\
                svc_name, conf_file)
        return -1
    else:
        data = StringIO('\n'.join(line.strip() for line in fp))
    # Parse conf file
    parser = ConfigParser.SafeConfigParser()
    try:
        parser.readfp(data)
    except ConfigParser.ParsingError as e:
        fp.close()
        if debug:
            print '{0}: Parsing error: {1}'.format(svc_name, \
                str(e))
        return -1
    # Read DEFAULT.http_server_port from the conf file. If that fails try
    # DEFAULTS.http_server_port (for python daemons)
    try:
        http_server_port = parser.getint('DEFAULT', 'http_server_port')
    except (ConfigParser.NoOptionError, ConfigParser.NoSectionError, \
            ValueError) as de:
        try:
            http_server_port = parser.getint('DEFAULTS', 'http_server_port')
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError) as dse:
            fp.close()
            if debug:
                print '{0}: DEFAULT/S.http_server_port not present'.format(
                    svc_name)
            return -1
        else:
            fp.close()
            return http_server_port
    else:
        fp.close()
        return http_server_port

_DEFAULT_CONF_FILE_DIR = '/etc/contrail/'
_DEFAULT_CONF_FILE_EXTENSION = '.conf'

def get_http_server_port_from_conf(svc_name, debug):
    # Open and extract conf file
    if svc_name in ServicesDefaultConfigurationFiles:
        default_conf_files = ServicesDefaultConfigurationFiles[svc_name]
    else:
        default_conf_files = [_DEFAULT_CONF_FILE_DIR + svc_name + \
            _DEFAULT_CONF_FILE_EXTENSION]
    for conf_file in default_conf_files:
        http_server_port = _get_http_server_port_from_conf(svc_name, conf_file,
                                                           debug)
        if http_server_port != -1:
            return http_server_port
    return -1

def get_default_http_server_port(svc_name, debug):
    if svc_name in ServiceHttpPortMap:
        return ServiceHttpPortMap[svc_name]
    else:
        if debug:
            print '{0}: Introspect port not found'.format(svc_name)
        return -1

def get_http_server_port(svc_name, debug):
    http_server_port = get_http_server_port_from_cmdline_options(svc_name, debug)
    if http_server_port == -1:
        http_server_port = get_http_server_port_from_conf(svc_name, debug)
    if http_server_port == -1:
        http_server_port = get_default_http_server_port(svc_name, debug)
    return http_server_port

def get_svc_uve_status(svc_name, debug, timeout):
#def get_svc_uve_status(svc_name, debug, timeout, keyfile, certfile, cacert):
# TODO: restore certs logic
    # Get the HTTP server (introspect) port for the service
    http_server_port = get_http_server_port(svc_name, debug)
    if http_server_port == -1:
        return None, None
    host = socket.gethostname()
    # Now check the NodeStatus UVE
    svc_introspect = IntrospectUtil(host, http_server_port, debug, \
                                    timeout)
# TODO: restore certs logic
#                                    timeout, keyfile, certfile, cacert)
    node_status = svc_introspect.get_uve('NodeStatus')
    if node_status is None:
        if debug:
            print '{0}: NodeStatusUVE not found'.format(svc_name)
        return None, None
    node_status = [item for item in node_status if 'process_status' in item]
    if not len(node_status):
        if debug:
            print '{0}: ProcessStatus not present in NodeStatusUVE'.format(
                svc_name)
        return None, None
    process_status_info = node_status[0]['process_status']
    if len(process_status_info) == 0:
        if debug:
            print '{0}: Empty ProcessStatus in NodeStatusUVE'.format(svc_name)
        return None, None
    description = process_status_info[0]['description']
    for connection_info in process_status_info[0].get('connection_infos', []):
        if connection_info.get('type') == 'ToR':
            description = 'ToR:%s connection %s' % (connection_info['name'], connection_info['status'].lower())
    return process_status_info[0]['state'], description

def get_svc_uve_info(svc_name, svc_status, debug, detail, timeout):
# TODO: restore certs logic
#def get_svc_uve_info(svc_name, svc_status, debug, detail, timeout, keyfile,
#                     certfile, cacert):
    # Extract UVE state only for running processes
    svc_uve_description = None
    if (svc_name in NodeUVEImplementedServices or
            svc_name.rsplit('-', 1)[0] in NodeUVEImplementedServices) and \
            svc_status == 'active':
        try:
            svc_uve_status, svc_uve_description = \
                get_svc_uve_status(svc_name, debug, timeout)
# TODO: restore certs logic
#                get_svc_uve_status(svc_name, debug, timeout, keyfile,\
#                                   certfile, cacert)
        except requests.ConnectionError, e:
            if debug:
                print 'Socket Connection error : %s' % (str(e))
            svc_uve_status = "connection-error"
        except (requests.Timeout, socket.timeout) as te:
            if debug:
                print 'Timeout error : %s' % (str(te))
            svc_uve_status = "connection-timeout"

        if svc_uve_status is not None:
            if svc_uve_status == 'Non-Functional':
                svc_status = 'initializing'
            elif svc_uve_status == 'connection-error':
                if svc_name in BackupImplementedServices:
                    svc_status = 'backup'
                else:
                    svc_status = 'initializing'
            elif svc_uve_status == 'connection-timeout':
                svc_status = 'timeout'
        else:
            svc_status = 'initializing'
        if svc_uve_description is not None and svc_uve_description is not '':
            svc_status = svc_status + ' (' + svc_uve_description + ')'

    return svc_status
# end get_svc_uve_info

client = docker.from_env()

def container_status(pod,svc_name):

   cont_label = {CONTRAIL_POD_LABEL: pod, CONTRAIL_SVC_LABEL: svc_name}
   cont_filter = get_label_filter(cont_label)

   containers = client.containers(filters=cont_filter)

   if containers:
      if len(containers) > 1:
         error = "Error: %d instances of %s running" % (len(containers), svc_name)
         return error
      else:
         contrail_container = containers.pop()
         if contrail_container["State"] == "running":
            return "active"
         else:
            return "inactive"
   else:
      # the below logic expects that contrail thirdparty resources which are running as
      # k8s pods should follow below container naming format in manifests/helm charts
      # pod-svc_name
      #
      # Few examples:
      # config-database-cassandra
      # config-database-zookeeper
      # config-database-rabbitmq

      # As redis container does not have any contrail svc labels
      if svc_name == "redis":
         svc_containers = client.containers()
      else:
         svc_label = {CONTRAIL_SVC_LABEL: svc_name}
         svc_filter = get_label_filter(svc_label)
         svc_containers = client.containers(filters=svc_filter)

      for container in svc_containers:
         cont_labels = container["Labels"]
         for key, val in cont_labels.iteritems():
            if key == K8S_CONTAINER_NAME_LABEL:
               k8s_container_name = pod + "-" + svc_name
               if val == k8s_container_name:
                  if container["State"] == "running":
                     return "active"
                  else:
                     return "inactive"

   return "inactive"
# end of container_status

def get_label_filter(label_dict=None):

   if not label_dict:
      label_dict = {}

   label_list = []
   for key, value in label_dict.iteritems():
      if not value:
         label_list.append(key)
      else:
         filter = key + "=" + value
         label_list.append(filter)

   return {"label": label_list}

# end of get_label_filter

def is_pod_present(pod):

   pod_label = {CONTRAIL_POD_LABEL: pod}
   pod_filter = get_label_filter(pod_label)

   containers = client.containers(filters=pod_filter)

   # If no container exists with regular labels
   # then look for configdb and analyticsdb running as k8s pods
   if not containers:
      k8s_pod_label = {CONTRAIL_SVC_LABEL: None}
      k8s_filter =  get_label_filter(k8s_pod_label)

      containers = client.containers(filters=k8s_filter)
      if not containers:
         return False

      for container in containers:
         cont_labels = container["Labels"]
         for key, val in cont_labels.iteritems():
            if key == K8S_CONTAINER_NAME_LABEL:
               if val.startswith(pod):
                  return True
      return False
   else:
      return True
# end of is_pod_present

def contrail_service_status(pod, options):
    ppod = pod.title()
    print "== Contrail " + ppod + " =="
    for svc_name in CONTRAIL_SERVICES[pod]:
       psvc = svc_name + ': '
       status = container_status(pod, svc_name)
       if pod in ['vrouter', 'control', 'config', 'analytics', 'kubernetes']:
          sandesh_svc = CONTRAIL_SERVICES[pod][svc_name]
          status = get_svc_uve_info(sandesh_svc, status, options.debug,
                options.detail, options.timeout)
# TODO: restore certs logic
#                options.detail, options.timeout, options.keyfile,
#                options.certfile, options.cacert)
       print (psvc + status)


def main():

    parser = OptionParser()
    parser.add_option('-d', '--detail', dest='detail',
                      default=False, action='store_true',
                      help="show detailed status")
    parser.add_option('-x', '--debug', dest='debug',
                      default=False, action='store_true',
                      help="show debugging information")
    parser.add_option('-t', '--timeout', dest='timeout', type="float",
                      default=2,
                      help="timeout in seconds to use for HTTP requests to services")
# TODO: restore certs logic
#    parser.add_option('-k', '--keyfile', dest='keyfile', type="string",
#                      default="/etc/contrail/ssl/private/server-privkey.pem",
#                      help="ssl key file to use for HTTP requests to services")
#    parser.add_option('-c', '--certfile', dest='certfile', type="string",
#                      default="/etc/contrail/ssl/certs/server.pem",
#                      help="certificate file to use for HTTP requests to services")
#    parser.add_option('-a', '--cacert', dest='cacert', type="string",
#                      default="/etc/contrail/ssl/certs/ca-cert.pem",
#                      help="ca-certificate file to use for HTTP requests to services")

    (options, args) = parser.parse_args()

    vrouter = is_pod_present(pod="vrouter")
    control = is_pod_present(pod="control")
    config = is_pod_present(pod="config")
    config_database = is_pod_present(pod="config-database")
    analytics = is_pod_present(pod="analytics")
    analytics_database = is_pod_present(pod="analytics-database")
    webui = is_pod_present(pod="webui")
    kubernetes = is_pod_present(pod="kubernetes")

    vr = False
    lsmodout = None
    lsofvrouter = None
    try:
        lsmodout = subprocess.Popen('lsmod', stdout=subprocess.PIPE).communicate()[0]
    except Exception as lsmode:
        if options.debug:
            print 'lsmod FAILED: {0}'.format(str(lsmode))
    try:
        lsofvrouter = (subprocess.Popen(['lsof', '-ni:{0}'.format(DPDK_NETLINK_TCP_PORT),
                   '-sTCP:LISTEN'], stdout=subprocess.PIPE).communicate()[0])
    except Exception as lsofe:
        if options.debug:
            print 'lsof -ni:{0} FAILED: {1}'.format(DPDK_NETLINK_TCP_PORT, str(lsofe))

    if lsmodout and lsmodout.find('vrouter') != -1:
        vr = True

    elif lsofvrouter:
        vr = True

    if vrouter:
        if not vr:
            print "vRouter is NOT PRESENT"
        else:
            print "vRouter is PRESENT"
        contrail_service_status('vrouter', options)
        print ""

    if control:
        contrail_service_status('control', options)
        print ""

    if config:
        contrail_service_status('config', options)
        print ""

    if config_database:
        contrail_service_status('config-database', options)
        print ""

    if analytics:
        contrail_service_status('analytics', options)
        print ""

    if analytics_database:
        contrail_service_status('analytics-database', options)
        print ""

    if webui:
        contrail_service_status('webui', options)
        print ""

    if kubernetes:
        contrail_service_status('kubernetes', options)
        print ""

if __name__ == '__main__':
    main()
