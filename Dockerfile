FROM larsks/runit
MAINTAINER lars@oddbit.com

RUN yum -y install \
	python-pbr \
	git \
	python-devel \
	python-setuptools \
	python-pip \
	gcc \
	libxml2-python \
	libxslt-python \
	python-lxml \
	sqlite \
	python-repoze-lru  \
	crudini \
	yum-utils

# This pulls in all the dependencies of the python-glance package
# without actually installing python-glance (because we're going to install
# that from source).
RUN yum -y install $(repoquery --requires python-nova | awk '{print $1}')

# Download and install glance from source.
WORKDIR /opt
RUN git clone http://github.com/openstack/nova.git
WORKDIR /opt/nova
RUN python setup.py install
RUN bash tools/config/generate_sample.sh -b . -p nova -o etc/nova

# Install the sample configuration files.
RUN mkdir -p /etc/nova

RUN cp etc/nova/nova.conf.sample /etc/nova/nova.conf
RUN cp etc/nova/api-paste.ini /etc/nova/
RUN cp etc/nova/policy.json /etc/nova/
RUN cp etc/nova/rootwrap.conf /etc/nova
RUN cp -r etc/nova/rootwrap.d /etc/nova


RUN crudini --del /etc/nova/nova.conf \
	DEFAULT \
	log_file
RUN crudini --set /etc/nova/nova.conf \
	DEFAULT \
	verbose \
	true
RUN crudini --set /etc/nova/nova.conf \
	DEFAULT \
	rpc_backend \
	rabbit
RUN crudini --set /etc/nova/nova.conf \
	DEFAULT \
	rabbit_host \
	amqphost
RUN crudini --set /etc/nova/nova.conf \
	DEFAULT \
	state_path \
	/srv/nova-controller
RUN crudini --set /etc/nova/nova.conf \
	database \
	connection \
	sqlite:////srv/nova-controller/nova.db

RUN crudini --del /etc/nova/nova.conf \
	keystone_authtoken \
	auth_host
RUN crudini --del /etc/nova/nova.conf \
	keystone_authtoken \
	auth_port
RUN crudini --del /etc/nova/nova.conf \
	keystone_authtoken \
	auth_protocol
RUN crudini --set /etc/nova/nova.conf \
	keystone_authtoken \
	auth_uri \
	http://keystone:5000/
RUN crudini --set /etc/nova/nova.conf \
	keystone_authtoken \
	admin_user \
	nova
RUN crudini --set /etc/nova/nova.conf \
	keystone_authtoken \
	admin_password \
	secret
RUN crudini --set /etc/nova/nova.conf \
	keystone_authtoken \
	admin_tenant_name \
	services

ADD nova.sudoers /etc/sudoers.d

RUN useradd -r -d /srv/nova-controller -m nova

VOLUME /srv/nova-controller
EXPOSE 8773
EXPOSE 8774
EXPOSE 8775

