#!/bin/sh

cd /opt/nova

cp etc/nova/nova.conf.sample /etc/nova/nova.conf
cp etc/nova/api-paste.ini /etc/nova/
cp etc/nova/policy.json /etc/nova/
cp etc/nova/rootwrap.conf /etc/nova
cp -r etc/nova/rootwrap.d /etc/nova
