#!/bin/sh

crudini --del /etc/nova/nova.conf \
	DEFAULT \
	log_file
crudini --set /etc/nova/nova.conf \
	DEFAULT \
	verbose \
	true
crudini --set /etc/nova/nova.conf \
	DEFAULT \
	rpc_backend \
	rabbit
crudini --set /etc/nova/nova.conf \
	DEFAULT \
	rabbit_host \
	rabbitmq
crudini --set /etc/nova/nova.conf \
	DEFAULT \
	firewall_driver \
	nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf \
	DEFAULT \
	state_path \
	/srv/nova-controller
crudini --del /etc/nova/nova.conf \
	keystone_authtoken \
	auth_host
crudini --del /etc/nova/nova.conf \
	keystone_authtoken \
	auth_port
crudini --del /etc/nova/nova.conf \
	keystone_authtoken \
	auth_protocol
crudini --set /etc/nova/nova.conf \
	keystone_authtoken \
	auth_uri \
	http://keystone:5000/
crudini --set /etc/nova/nova.conf \
	keystone_authtoken \
	identity_uri \
	http://keystone:35357/
crudini --set /etc/nova/nova.conf \
	keystone_authtoken \
	admin_user \
	nova
crudini --set /etc/nova/nova.conf \
	keystone_authtoken \
	admin_tenant_name \
	services
crudini --set /etc/nova/nova.conf \
	glance \
	host \
	glance
