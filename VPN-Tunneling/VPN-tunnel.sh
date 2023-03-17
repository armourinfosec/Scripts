#!/bin/bash

# get ssh connection for root access
read -p "Target SSH username: " ssh_username
read -p "Target SSH IP address: " ssh_ip
read -s -p "Target SSH root password: " ssh_password

# SSH into remote server and set up tunnel
sshpass -p $ssh_password ssh -o StrictHostKeyChecking=no $ssh_username@$ssh_ip << EOF

# Enable root login and tunneling
sed -i 's/#PermitTunnel no/PermitTunnel yes/' /etc/ssh/sshd_config
sed -i 's/#PermitTunnel yes/PermitTunnel yes/' /etc/ssh/sshd_config
systemctl restart sshd

EOF

# Connect to remote server and run ip addr show command
sshpass -p "$ssh_password" ssh -o StrictHostKeyChecking=no "$ssh_username@$ssh_ip" "ip addr show && route" > output.txt

# Extract IP and interface name from output
IP=$(grep -oP 'inet \K\S+' output.txt | sed -n 2p | awk -F '/' '{print $1}')
IP_GW=$(grep -oP 'inet \K\S+' output.txt | sed -n 2p)
interface_name=$(grep -oP '\d+: [a-zA-Z0-9@_.-]+' output.txt | head -n2 | tail -n1 | cut -d' ' -f2)
Range=$(tail -n 1 output.txt | awk '{print $1}')

# Print results
echo "Target IP Address: ${IP[0]}"
echo "Target IP Address With GW : $IP_GW"
echo "Target IP Interface Name: $interface_name"
echo "Target IP Ragne : $Range"
# ssh into the server and modify sshd_config
ssh -f "$ssh_username@$ssh_ip" -w any:any sleep 2

# create VPN tunnel on local machine
ip addr add 10.0.0.1/24 peer $IP_GW dev tun0
ifconfig tun0 up

# create VPN tunnel on server
sshpass -p $ssh_password ssh $ssh_username@$ssh_ip "ip addr add 10.0.0.2/24 peer 10.0.0.1/24 dev tun0 && ifconfig tun0 up && echo 1 > /proc/sys/net/ipv4/ip_forward && iptables -t nat -A POSTROUTING -s 10.0.0.1 -o $interface_name -j MASQUERADE"

# add route for VPN network
route add -net $Range/24 gw $IP
