# config for playing with IPv6

----
"Stateful" IPv6 host
----

IPv6 address is acquired by DHCPv6 (wide-dhcpv6-server on the gateway), while
IPv6 prefix and gateway info is acquired by RA (radvd on the gateway)

usage:
  - start: `./start_dhcpv6-client`
  * test IPv6 connection: `./ping6_google_dns`
  *   . . .
  * stop: `./stop_dhcpv6-client`

*refer pkg_depends_on.txt for package dependency info.  
if the main network interface is other than "eth0", please try to run `./replace_eth0_with_other_if [interface]`. It will replace "eth0" with "interface".*
