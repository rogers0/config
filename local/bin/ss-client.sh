#!/bin/sh

SSCONFIG=/etc/shadowsocks-libev/config.json
DNSPORT=65353
RESOLV=/etc/resolv.conf
SSRESOLV=${RESOLV}.ss-client

if [ ! -f $SSCONFIG ]; then
  echo no config file: $SSCONFIG
  exit 1
fi

SSSERVER=$(grep server $SSCONFIG|grep -v server_port|grep -v nameserver|grep -v server_port|cut -d\" -f4)
SSPORT=$(grep server_port $SSCONFIG|cut -d: -f2|cut -d, -f1)
SSLOCAL=$(grep local_port $SSCONFIG|cut -d: -f2|cut -d, -f1)
SSDNS=$(grep nameserver /etc/shadowsocks-libev/config_mars.json|cut -d: -f2|cut -d\" -f2)

# Reset iptables and stop all services by this script
if [ -f /run/ss-redir.pid ]; then
  kill $(cat /run/ss-redir.pid)
  rm -f /run/ss-redir.pid
fi
killall ss-tunnel 2>/dev/null
systemctl stop dnsmasq
/etc/init.d/dnsmasq stop
start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile /run/dnsmasq/dnsmasq.pid --name dnsmasq
iptables -F > /dev/null 2>&1
iptables -t nat -F > /dev/null 2>&1
iptables -t mangle -F > /dev/null 2>&1
#ip route del local default dev lo table 100
#ip rule del fwmark 1 lookup 100

# Exit if there's a param in cmd line
if [ -n "$1" ]; then
  [ -n "$SSRESOLV" -a -n "$RESOLV" -a -e "$SSRESOLV" ] &&
    rm -f "$RESOLV" &&
    mv "$SSRESOLV" "$RESOLV"
  exit 0
fi
echo SS CONFIG:
echo SERVER=$SSSERVER PORT=$SSPORT LOCAL=$SSLOCAL DNS=$SSDNS

# Ignore your shadowsocks server's addresses
# It's very IMPORTANT, just be careful.
iptables -t nat -A OUTPUT -d $SSSERVER -j RETURN

# Ignore LANs and any other addresses you'd like to bypass the proxy
# See Wikipedia and RFC5735 for full list of reserved networks.
# See ashi009/bestroutetb for a highly optimized CHN route list.
iptables -t nat -A OUTPUT -d 0.0.0.0/8 -j RETURN
iptables -t nat -A OUTPUT -d 10.0.0.0/8 -j RETURN
iptables -t nat -A OUTPUT -d 127.0.0.0/8 -j RETURN
iptables -t nat -A OUTPUT -d 169.254.0.0/16 -j RETURN
iptables -t nat -A OUTPUT -d 172.16.0.0/12 -j RETURN
iptables -t nat -A OUTPUT -d 192.168.0.0/16 -j RETURN
iptables -t nat -A OUTPUT -d 224.0.0.0/4 -j RETURN
iptables -t nat -A OUTPUT -d 240.0.0.0/4 -j RETURN

# Anything else should be redirected to shadowsocks's local port
iptables -t nat -A OUTPUT -p tcp -j REDIRECT --to-ports $SSLOCAL

ss-redir -a nobody -c $SSCONFIG -f /run/ss-redir.pid
ss-tunnel -a nobody -b 0.0.0.0 -l $DNSPORT -c $SSCONFIG -L $SSDNS:53 /run/ss-tunnel.pid &
[ -n "$SSRESOLV" -a -n "$RESOLV" -a -f "$RESOLV" -a ! -e "$SSRESOLV" ] &&
  mv "$RESOLV" "$SSRESOLV"
echo nameserver 127.0.0.1 > "$RESOLV"

mkdir -p /run/dnsmasq
chown dnsmasq:nogroup /run/dnsmasq
start-stop-daemon --start --quiet --pidfile /run/dnsmasq/dnsmasq.pid --exec $(which dnsmasq) -- -x /run/dnsmasq/dnsmasq.pid -u dnsmasq --local-service --no-poll --no-resolv --conf-file=/dev/null --conf-dir= --cache-size=5000 --server=127.0.0.1\#$DNSPORT
# --log-queries
