FROM larsks/runit:fedora20
MAINTAINER Lars Kellogg-Stedman <lars@oddbit.com>

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
RUN yum -y install \
	python-fixtures \
	python-mox
RUN bash tools/config/generate_sample.sh -b . -p nova -o etc/nova

# Install the sample configuration files.
RUN mkdir -p /etc/nova

ADD install-config.sh /opt/nova/install-config.sh
RUN sh /opt/nova/install-config.sh

ADD configure-nova.sh /opt/nova/configure-nova.sh
RUN sh /opt/nova/configure-nova.sh

ADD nova.sudoers /etc/sudoers.d/nova
RUN chmod 440 /etc/sudoers.d/nova

RUN useradd -r -d /srv/nova-controller -m nova
ADD service/ /service/

VOLUME /srv/nova-controller
EXPOSE 8773
EXPOSE 8774
EXPOSE 8775

ADD nova.sysinit /etc/runit/sysinit/nova

