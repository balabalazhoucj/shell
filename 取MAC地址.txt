#!/bin/bash
#取MAC
ifconfig eth1 | awk 'NR==1{print "HWADDR=" $5}' >> /etc/sysconfig/network-scripts/ifcfg-eth1