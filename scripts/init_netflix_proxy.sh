#!/bin/bash

iptables -t nat -A PREROUTING -p udp -i eth0 --dport 53 -j DNAT --to-destination 127.0.0.1:5300
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 80 -j DNAT --to-destination 127.0.0.1:8080
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 443 -j DNAT --to-destination 127.0.0.1:4430

if [[ ! -f /etc/iptables.rules ]] ; then
  iptables-save > /etc/iptables.rules
  echo created /etc/iptables.rules
fi

echo echo "crontabl -e"
echo echo "add next line:"
echo "*/7 * * * * /opt/netflix-proxy/scripts/update_firewall.pl"

