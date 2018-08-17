from optparse import OptionParser
import subprocess
import ConfigParser
import operator
import socket
import requests
import warnings
import docker
import six
import os.path
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
from lxml import etree
from sandesh_common.vns.constants import ServiceHttpPortMap
from sandesh_common.vns.constants import NodeUVEImplementedServices
from sandesh_common.vns.constants import BackupImplementedServices


CONTRAIL_SERVICES_TO_SANDESH_SVC = {
    'vrouter': {
        'nodemgr': 'contrail-vrouter-nodemgr',
        'agent': 'contrail-vrouter-agent',
    },
    'control': {
        'nodemgr': 'contrail-control-nodemgr',
        'control': 'contrail-control',
        'named': 'contrail-named',
        'dns': 'contrail-dns',
    },
    'config': {
        'nodemgr': 'contrail-config-nodemgr',
        'api': 'contrail-api',
        'schema': 'contrail-schema',
        'svc-monitor': 'contrail-svc-monitor',
        'device-manager': 'contrail-device-manager',
    },
    'config-database': {
        'nodemgr': 'contrail-config-database-nodemgr',
        'cassandra': None,
        'zookeeper': None,
        'rabbitmq': None,
    },
    'analytics': {
        'nodemgr': 'contrail-analytics-nodemgr',
        'api': 'contrail-analytics-api',
        'collector': 'contrail-collector',
        'query-engine': 'contrail-query-engine',
    },
    'kubernetes': {
        'kube-manager': 'contrail-kube-manager',
    },
    'database': {
        'nodemgr': 'contrail-database-nodemgr',
        'cassandra': None,
        'zookeeper': None,
    },
    'webui': {
        'web': None,
        'job': None,
    }
}

alarm_enable = os.getenv('ENABLE_ANALYTICS_ALARM', 'False')
underlay_overlay_enable = os.getenv('ENABLE_ANALYTICS_UNDERLAY_OVERLAY', 'False')

if alarm_enable == 'True':
    CONTRAIL_SERVICES_TO_SANDESH_SVC['analytics']['alarm-gen'] = \
        'contrail-alarm-gen'
    CONTRAIL_SERVICES_TO_SANDESH_SVC['database']['kafka'] = None
if underlay_overlay_enable == 'True':
    CONTRAIL_SERVICES_TO_SANDESH_SVC['analytics']['snmp-collector'] = \
        'contrail-snmp-collector'
    CONTRAIL_SERVICES_TO_SANDESH_SVC['analytics']['topology'] = \
        'contrail-topology'

# TODO: Include vcenter-plugin


debug_output = False


def print_debug(str):
    if debug_output:
        print("DEBUG: " + str)


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

        return a_list if a_list else None
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
        return f[0].text if len(f) else None
    #end find_entry
#end class EtreeToDict


class IntrospectUtil(object):
    def __init__(self, ip, port, timeout, keyfile, certfile, cacert):
        self._ip = ip
        self._port = port
        self._timeout = timeout
        self._certfile = certfile
        self._keyfile = keyfile
        self._cacert = cacert
    #end __init__

    def _mk_url_str(self, path, secure=False):
        if secure:
            return "https://%s:%d/%s" % (self._ip, self._port, path)
        return "http://%s:%d/%s" % (self._ip, self._port, path)
    #end _mk_url_str

    def _load(self, path):
        resp = None
        url = self._mk_url_str(path)
        try:
            resp = requests.get(url, timeout=self._timeout)
        except requests.ConnectionError:
            if os.path.isfile(self._cacert) and \
               os.path.isfile(self._certfile) and \
               os.path.isfile(self._keyfile):
                url = self._mk_url_str(path, True)
                try:
                    resp = requests.get(url, timeout=self._timeout,
                      verify=self._cacert, cert=(self._certfile, self._keyfile))
                except Exception as e:
                   print e
                   return None
        if resp:
            if resp.status_code != requests.codes.ok:
                print_debug('URL: %s : HTTP error: %s' % (url, str(resp.status_code)))
                return None
        else:
            return None

        return etree.fromstring(resp.text)
    #end _load

    def get_uve(self, tname):
        path = 'Snh_SandeshUVECacheReq?x=%s' % (tname)
        xpath = './/' + tname
        p = self._load(path)
        if p is None:
            print_debug('UVE: %s : not found' % (path))
            return None

        return EtreeToDict(xpath).get_all_entry(p)
    #end get_uve
#end class IntrospectUtil


def get_http_server_port(svc_name):
    # TODO: additionaly the Introspect port can be obtained from containers env.
    if svc_name in ServiceHttpPortMap:
        return ServiceHttpPortMap[svc_name]

    print_debug('{0}: Introspect port not found'.format(svc_name))
    return None


def get_svc_uve_status(svc_name, timeout, keyfile, certfile, cacert):
    # Get the HTTP server (introspect) port for the service
    http_server_port = get_http_server_port(svc_name)
    if not http_server_port:
        return None, None
    host = socket.gethostname()
    # Now check the NodeStatus UVE
    svc_introspect = IntrospectUtil(host, http_server_port,
                                    timeout, keyfile, certfile, cacert)
    node_status = svc_introspect.get_uve('NodeStatus')
    if node_status is None:
        print_debug('{0}: NodeStatusUVE not found'.format(svc_name))
        return None, None
    node_status = [item for item in node_status if 'process_status' in item]
    if not len(node_status):
        print_debug('{0}: ProcessStatus not present in NodeStatusUVE'.format(svc_name))
        return None, None
    process_status_info = node_status[0]['process_status']
    if len(process_status_info) == 0:
        print_debug('{0}: Empty ProcessStatus in NodeStatusUVE'.format(svc_name))
        return None, None
    description = process_status_info[0]['description']
    for connection_info in process_status_info[0].get('connection_infos', []):
        if connection_info.get('type') == 'ToR':
            description = 'ToR:%s connection %s' % (connection_info['name'], connection_info['status'].lower())
    return process_status_info[0]['state'], description


def get_svc_uve_info(svc_name, svc_status, detail, timeout, keyfile,
                     certfile, cacert):
    # Extract UVE state only for running processes
    svc_uve_description = None
    if ((svc_name in NodeUVEImplementedServices
                or svc_name.rsplit('-', 1)[0] in NodeUVEImplementedServices)
            and svc_status == 'active'):
        try:
            svc_uve_status, svc_uve_description = \
                get_svc_uve_status(svc_name, timeout, keyfile,
                                   certfile, cacert)
        except requests.ConnectionError, e:
            print_debug('Socket Connection error : %s' % (str(e)))
            svc_uve_status = "connection-error"
        except (requests.Timeout, socket.timeout) as te:
            print_debug('Timeout error : %s' % (str(te)))
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


def contrail_service_status(pods, pod, options):
    print("== Contrail {} ==".format(pod))
    pod_map = CONTRAIL_SERVICES_TO_SANDESH_SVC.get(pod)
    if not pod_map:
        print('')
        return

    for service, internal_svc_name in six.iteritems(pod_map):
        status = 'inactive'
        container = pods[pod].get(service)
        if container and container.get('State') == 'running':
            status = 'active'
        if internal_svc_name:
            status = get_svc_uve_info(internal_svc_name, status,
                options.detail, options.timeout, options.keyfile,
                options.certfile, options.cacert)
        print('{}: {}'.format(service, status))

    print('')


def get_pod_from_env(client, cid):
    cnt_full = client.inspect_container(cid)
    env = cnt_full['Config'].get('Env')
    if not env:
        return None
    node_type = next(iter(
        [i for i in env if i.startswith('NODE_TYPE=')]), None)
    # for now pod equals to NODE_TYPE
    return node_type.split('=')[1] if node_type else None


def get_containers():
    # TODO: try to reuse this logic with nodemgr

    items = dict()
    client = docker.from_env()
    flt = {'label': ['net.juniper.contrail.container.name']}
    for cnt in client.containers(all=True, filters=flt):
        labels = cnt.get('Labels', dict())
        if not labels:
            continue
        service = labels.get('net.juniper.contrail.service')
        if not service:
            # filter only service containers (skip *-init, contrail-status)
            continue
        pod = labels.get('net.juniper.contrail.pod')
        if not pod:
            pod = get_pod_from_env(client, cnt['Id'])
        name = labels.get('net.juniper.contrail.container.name')

        key = '{}.{}'.format(pod, service) if pod and service else name
        item = {
            'Pod': pod if pod else '',
            'Service': service if service else '',
            'Original Name': name,
            'State': cnt['State'],
            'Status': cnt['Status'],
            'Created': cnt['Created']
        }
        if key not in items:
            items[key] = item
            continue
        if cnt['State'] != items[key]['State']:
            if cnt['State'] == 'running':
                items[key] = container
            continue
        # if both has same state - add latest.
        if cnt['Created'] > items[key]['Created']:
            items[key] = cnt

    return items


def print_containers(containers):
    # containers is a dict of dicts
    hdr = ['Pod', 'Service', 'Original Name', 'State', 'Status']
    items = list()
    items.extend([v[hdr[0]], v[hdr[1]], v[hdr[2]], v[hdr[3]], v[hdr[4]]]
                 for k, v in six.iteritems(containers))
    items.sort(key=operator.itemgetter(0, 1))
    items.insert(0, hdr)

    cols = [1 for _ in xrange(0, len(items[0]))]
    for item in items:
        for i in xrange(0, len(cols)):
            cl = 2 + len(item[i])
            if cols[i] < cl:
                cols[i] = cl
    for i in xrange(0, len(cols)):
        cols[i] = '{{:{}}}'.format(cols[i])
    for item in items:
        res = ''
        for i in xrange(0, len(cols)):
            res += cols[i].format(item[i])
        print(res)
    print('')


def parse_args():
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
    parser.add_option('-k', '--keyfile', dest='keyfile', type="string",
                      default="/etc/contrail/ssl/private/server-privkey.pem",
                      help="ssl key file to use for HTTP requests to services")
    parser.add_option('-c', '--certfile', dest='certfile', type="string",
                      default="/etc/contrail/ssl/certs/server.pem",
                      help="certificate file to use for HTTP requests to services")
    parser.add_option('-a', '--cacert', dest='cacert', type="string",
                      default="/etc/contrail/ssl/certs/ca-cert.pem",
                      help="ca-certificate file to use for HTTP requests to services")
    options, _ = parser.parse_args()
    return options


def main():
    global debug_output

    options = parse_args()
    debug_output = options.debug

    containers = get_containers()
    print_containers(containers)

    # first check and store containers dict as a tree
    fail = False
    pods = dict()
    for k, v in six.iteritems(containers):
        pod = v['Pod']
        service = v['Service']
        if pod and service:
            pods.setdefault(pod, dict())[service] = v
            continue
        print("WARNING: container with original name '{}' "
              "have Pod os Service empty. Pod: '{}' / Service: '{}'. "
              "Please pass NODE_TYPE with pod name to container's env".format(
                  v['Original Name'], v['Pod'], v['Service']))
        fail = True
    if fail:
        print('')

    vrouter_driver = False
    try:
        lsmod = subprocess.Popen('lsmod', stdout=subprocess.PIPE).communicate()[0]
        if lsmod.find('vrouter') != -1:
            vrouter_driver = True
            print("vrouter kernel module is PRESENT")
    except Exception as ex:
        print_debug('lsmod FAILED: {0}'.format(ex))
    try:
        lsof = (subprocess.Popen(
            ['netstat', '-xl'], stdout=subprocess.PIPE).communicate()[0])
        if lsof.find('dpdk_netlink') != -1:
            vrouter_driver = True
            print("vrouter DPDK module is PRESENT")
    except Exception as ex:
        print_debug('lsof FAILED: {0}'.format(ex))
    if 'vrouter' in pods and not vrouter_driver:
        print("vrouter driver is not PRESENT but agent pod is present")

    for pod in pods:
        contrail_service_status(pods, pod, options)


if __name__ == '__main__':
    main()
