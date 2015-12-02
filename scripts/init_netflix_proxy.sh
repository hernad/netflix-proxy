#!/bin/bash

if [[ ! -f /etc/iptables.rules ]] ; then
  iptables-save > /etc/iptables.rules
  echo created /etc/iptables.rules
fi

echo build docker images
cd /opt/netflix-proxy
./build.sh -b 1


sleep 5

BIND_CONTAINER_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' bind`
iptables -t nat -I PREROUTING -p udp -i eth0 --dport 53 -j DNAT --to-destination $BIND_CONTAINER_IP:53

SNIPROXY_CONTAINER_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' sniproxy`
iptables -t nat -I PREROUTING -s adsl.out.ba/32 -i eth0 -p tcp --dport 80  -j DNAT --to-dest $SNIPROXY_CONTAINER_IP:80
iptables -t nat -I PREROUTING -s adsl.out.ba/32 -i eth0 -p tcp --dport 443 -j DNAT --to-dest $SNIPROXY_CONTAINER_IP:443

iptables -F FRIENDS
iptables-save > /etc/iptables.rules

echo /etc/iptables.rules koristi update_firewall.pl skripta

echo echo "crontab -e"
echo echo "add next line:"
echo "*/7 * * * * /opt/netflix-proxy/scripts/update_firewall.pl"

