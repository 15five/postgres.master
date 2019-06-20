#!/bin/bash

# This script sets up a delay between master and mirror
# This delay can be used to replicate the replication lag
# sometimes seen in production.
# This script should be run on master.

tc qdisc del dev eth0 root
tc qdisc add dev eth0 root handle 1: prio
tc qdisc add dev eth0 parent 1:1 handle 10: netem delay 0ms
tc qdisc add dev eth0 parent 1:2 handle 20: netem delay 0ms
tc qdisc add dev eth0 parent 1:3 handle 30: netem delay 3000ms

MIRROR_IP=$(ping -c 1 mirror1 | awk '/bytes from/ { print $4 }' | sed s'/://')
echo "MIRROR IP: $MIRROR_IP"
tc filter add dev eth0 protocol ip parent 1: prio 3 u32 \
    match ip dst ${MIRROR_IP}/32 flowid 1:3

tc -s qdisc ls dev eth0
tc -s class show dev eth0
tc filter show dev eth0

# The following can be used to alter the delay to 0ms
# tc qdisc change dev eth0 parent 1:3 handle 30: netem delay 0ms

