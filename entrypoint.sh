#!/bin/bash

/usr/sbin/sshd

# Set hostname
echo `hostname -f` > /var/spool/torque/server_name

# Setup the torque queue.
/torque.setup root

# Build up the nodes and hosts file
: > /var/spool/torque/server_priv/nodes
IFS=","
for node in $NODES
do
    name=$( echo $node | awk 'BEGIN { FS = " " } ; { print $1 }' )
    host=$( echo $node | awk 'BEGIN { FS = " " } ; { print $2 }' )
    prop=$( echo $node | awk 'BEGIN { FS = " " } ; { $1 = ""; $2 = ""; gsub(/^[ \t]+/,"",$0); gsub(/[ \t]+$/,"",$0); print $0 }' )
    
    echo "$name $host" >> /etc/hosts
    echo "$name $prop" >> /var/spool/torque/server_priv/nodes
done

# Stop pbs_server
qterm

pbs_sched

# Start pbs_server in the foreground. With logging to stdout
pbs_server -D -L /dev/stdout