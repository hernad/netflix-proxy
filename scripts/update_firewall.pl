#!/usr/bin/perl -w

# restart the firewall if the IP address changed
# /etc/sysconfig/iptables

use strict;

print "start\n";

pAllow("adsl.out.ba");

sub pAllow {
  my ($aName) = @_;
  print "aName: $aName\n";
  my $vAddress = readpipe("host $aName | grep address | cut -d \" \" -f4");
  chomp $vAddress;
  print "vAddress: $vAddress\n";
  if ($vAddress ne "") {
    if (system("/sbin/iptables -L | grep -i $vAddress > /dev/null") != 0) {
      print "iptables-restore\n";
      system "/sbin/iptables-restore < /etc/iptables.rules" ;
      system "export SNIPROXY_CONTAINER_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' sniproxy` ; iptables -t nat -I PREROUTING -s adsl.out.ba/32 -i eth0 -p tcp --dport 80 -j DNAT --to-dest \$SNIPROXY_CONTAINER_IP:80 ; iptables -t nat -I PREROUTING -s adsl.out.ba/32 -i eth0 -p tcp --dport 443 -j DNAT --to-dest \$SNIPROXY_CONTAINER_IP:443" ;
      system "export BIND_CONTAINER_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' bind` ; iptables -t nat -I PREROUTING -s adsl.out.ba/32 -p udp -i eth0 --dport 53 -j DNAT --to-destination \$BIND_CONTAINER_IP:53";
      system "/usr/bin/docker restart bind sniproxy" ;
    }
  }
}
