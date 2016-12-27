# Stop the Neutron-server 
service neutron-server stop
# Stop the Neutron Open vSwicth agent
service neutron-openvswitch-agent stop
# Disable the OVS agent since we need ODL to be the manager of OVS
service neutron-openvswitch-agent disable
# Stop the OVS Service
service openvswitch-switch stop
# Remove any previous configuration of OVS
rm -rf /var/log/openvswitch/*
rm -rf /etc/openvswitch/conf.db
# Start the OVS service
service openvswitch-switch start
# Set ODL as manager on all nodes
ovs-vsctl set-manager tcp:${CONTROL_HOST}:6640
# Configure Neutron to use ODL
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers opendaylight 
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vxlan
cat <<EOT>> /etc/neutron/plugins/ml2/ml2_conf.ini 
[ml2_odl]
password = admin
username = admin
url = http://${CONTROL_HOST}:8080/controller/nb/v2/neutron
EOT

# Reset neutron's Database [Make sure you have installed neutron-db-manage utility]
mysql -e "drop database if exists neutron_ml2;"
mysql -e "create database neutron_ml2 character set utf8;"
mysql -e "grant all on neutron_ml2.* to 'neutron'@'%';"
neutron-db-manage --config-file /usr/share/neutron/neutron-dist.conf --config-file /etc/neutron/neutron.conf \
--config-file /etc/neutron/plugin.ini upgrade head

# restart Neutron Server
service neutron-server start
