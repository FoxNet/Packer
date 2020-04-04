#!/bin/bash -e
apt-get install --no-install-recommends -y dnsmasq
systemctl enable dnsmasq

# Copy over dnsmasq config
cp /tmp/build_files/dnsmasq/config/* /etc/dnsmasq.d/

# Add dnsmasq to resolved, if needed
if [ -f /etc/systemd/resolved.conf ]
then
    cat <<EOF> /etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
Domains=consul
Cache=no
EOF
fi
