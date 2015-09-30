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
