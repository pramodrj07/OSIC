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
