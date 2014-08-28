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

# This pulls in all the dependencies of the python-nova package
# without actually installing python-nova (because we're going to install
# that from source).
RUN yum -y install $(repoquery --requires python-nova | awk '{print $1}')

# Download and install nova from source.
WORKDIR /opt
RUN git clone http://github.com/openstack/nova.git
WORKDIR /opt/nova
RUN python setup.py install
RUN yum -y install \
	python-fixtures \
	python-mox

# Generate sample configuration files.
RUN bash tools/config/generate_sample.sh -b . -p nova -o etc/nova

# Install the sample configuration files.
RUN mkdir -p /etc/nova
ADD install-config.sh /opt/nova/install-config.sh
RUN sh /opt/nova/install-config.sh

# Configure things in nova.conf
ADD configure-nova.sh /opt/nova/configure-nova.sh
RUN sh /opt/nova/configure-nova.sh

ADD nova.sudoers /etc/sudoers.d/nova
RUN chmod 440 /etc/sudoers.d/nova

RUN useradd -r -d /srv/nova-controller -m nova

# Install runit services
ADD service/ /service/

VOLUME /srv/nova-controller
EXPOSE 8773 8774 8775

ADD nova.sysinit /etc/runit/sysinit/nova

# This is a hack to get nova-api and friends to run inside an
# unprivileged container.  This replaces /sbin/iptables-{save,restore}
# with a stub shell script.
ADD iptables-dummy /sbin/iptables-dummy
RUN mv /sbin/iptables-save /sbin/iptables-save-orig
RUN mv /sbin/iptables-restore /sbin/iptables-restore-orig
RUN ln -s /sbin/iptables-dummy /sbin/iptables-save
RUN ln -s /sbin/iptables-dummy /sbin/iptables-restore
