# config for playing with IPv6

----
native IPv6 by PPPoE over NTT B-Flets
----

config sample for Plala/OCN (2 major ISP in Japan). You need to add your own PPPoE account info in:
- /etc/ppp/chap-secrets
- /etc/ppp/peers/dslv6

usage
- start IPv6 PPPoE: `sysctl -p /etc/sysctl.d/ipv6.conf 2> /dev/null; pon dslv6`
- stop IPv6 PPPoE: `poff dslv6`

*refer pkg_depends_on.txt for package dependency info.  
if the main network interface is other than "eth0", please try to run `./replace_eth0_with_other_if [interface]`. It will replace "eth0" with "interface".*

----
IPv6 via Hurricane Electric Free IPv6 Tunnel Broker
----

usage0: IPv4 PPPoE + IPv6 tunnel (need global IP on the host by PPPoE, if not please look at usage1 below)
- start IPv4 PPPoE + IPv6 tunnel: `pon dsl`
- stop IPv4 PPPoE + IPv6 tunnel: `poff dsl`

usage1: NAT + IPv6 tunnel (on your gateway, you need to D-NAT all protocol 41 traffic to the host. Or, you can set up the host as DMZ)
- prepare0: create an account in [Hurricane Electric Free IPv6 Tunnel Broker](https://www.tunnelbroker.net)
- prepare1: edit "hev6tunnel.conf", set `NAT=1`, and other account info for the tunnel
- prepare2: simply add: `iptables -t nat -A PREROUTING -p 41 -i ppp0 -j DNAT --to $HOST_IP` on your gateway, if it's Linux
- start NAT + IPv6 tunnel: `./hev6tunnel`
- stop NAT + IPv6 tunnel: `./hev6tunnel stop`

*refer pkg_depends_on.txt for package dependency info.  
if the main network interface is other than "eth0", please try to run `./replace_eth0_with_other_if [interface]`. It will replace "eth0" with "interface".*

----
Stateful DHCPv6 server setting
----

usage:
- start native or tunnel IPv6 (refer 2 topics above)
  * native IPv6: `sysctl -p /etc/sysctl.d/ipv6.conf 2> /dev/null; pon dslv6`
  * IPv6 tunnel:
    . You need to apply a /48 prefix in [tunnelbroker.net's tunnel info page](https://www.tunnelbroker.net/tunnel_detail.php?tid=$TUNNELID), and write it to $IPV6PREFIX in "hev6tunnel.conf" file
    . start IPv6 tunnel: `./hev6tunnel`
- so other hosts in the same network segment can use the above IPv6 connection as gateway. Those hosts are called "stateful IPv6 host". refer "stateful_v6host" branch
  * `./start_dhcpv6-client`
  * `./ping6_google_dns`
  * . . .
  * `./stop_dhcpv6-client`

*refer pkg_depends_on.txt for package dependency info.  
if the main network interface is other than "eth0", please try to run `./replace_eth0_with_other_if [interface]`. It will replace "eth0" with "interface".*
