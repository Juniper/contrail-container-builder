# contrail-schema and contrail-api (as most of other config python services) share a lot of stuff (dependencies, common code, etc.)
# For now we will have one container for them (like controller/config/base container in upstream)

FROM centos:7.5.1804

# This is needed for lots of python-* stuff (some are just newer than in official repos)
COPY build-container/*.repo /etc/yum.repos.d

# TODO: most of this should be probably replaced with pip install -r requirements.txt
# this list taken basically by listing dependences of packages contrail-config and python-contrail inside upstream container
RUN yum -y install epel-release centos-release-openstack-queens \
&& yum update -y \
&& yum install -y \
    python-amqp \
    python-attrdict \
    python-bitarray \
    python-bottle \
    python-crypto \
    python-fysom \
    python-gevent \
    python-geventhttpclient \
    python-jsonpickle \
    python-kazoo \
    python-keystoneclient \
    python-keystonemiddleware \
    python-kombu \
    python-lxml \
    python-ncclient \
    python-netifaces \
    python-psutil \
    python-pycassa \
    python-pyhash \
    python-pysnmp \
    python-requests \
    python-setuptools \
    python-sqlalchemy \
    python-stevedore \
    python-subprocess32 \
    python-swiftclient \
    python-thrift \
    python-zope-interface \
    python2-jsonschema \
&& yum clean all \
&& rm -rf /var/cache/yum

# TODO: add provision scripts somewhere here
COPY repos/build/install/usr/lib/python2.7/ /usr/lib/python2.7/
COPY repos/build/install/usr/bin/contrail-api /usr/bin/

CMD ["/usr/bin/contrail-api"]


