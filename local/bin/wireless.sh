#!/bin/sh

WLAN=$(find /sys/class/net -follow -maxdepth 2 -name wireless 2>/dev/null|cut -d/ -f5|head -1)
echo ip link set $WLAN down
ip link set $WLAN down >/dev/null 2>&1

modprobe -r wl brcmsmac
modprobe -r cfg80211 brcmsmac cordic brcmutil bcma

if [ "$1" = "wl" ]; then
	modprobe wl
else
	modprobe brcmsmac
fi

sleep 0.1
WLAN=$(find /sys/class/net -follow -maxdepth 2 -name wireless 2>/dev/null|cut -d/ -f5|head -1)
echo ip link set $WLAN up
ip link set $WLAN up >/dev/null 2>&1
