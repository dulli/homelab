#!/usr/bin/env sh

# Clean up
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo ip6tables -P INPUT ACCEPT
sudo ip6tables -P OUTPUT ACCEPT

sudo iptables -F INPUT
sudo iptables -F OUTPUT
sudo ip6tables -F INPUT
sudo ip6tables -F OUTPUT

# Reiterate default rules
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo ip6tables -A INPUT -i lo -j ACCEPT
sudo ip6tables -A OUTPUT -o lo -j ACCEPT

sudo iptables -A INPUT -p icmp -j ACCEPT
sudo iptables -A OUTPUT -p icmp -j ACCEPT
sudo ip6tables -A INPUT -p ipv6-icmp -j ACCEPT
sudo ip6tables -A OUTPUT -p ipv6-icmp -j ACCEPT

sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo ip6tables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
sudo ip6tables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT

# Add firewall rules and set policy
sudo iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
sudo iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 853 -j ACCEPT
sudo iptables -A INPUT -p udp -m udp --dport 853 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 9001 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 51820 -j ACCEPT
sudo ip6tables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
sudo ip6tables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
sudo ip6tables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
sudo ip6tables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
sudo ip6tables -A INPUT -p tcp -m tcp --dport 853 -j ACCEPT
sudo ip6tables -A INPUT -p udp -m udp --dport 853 -j ACCEPT
sudo ip6tables -A INPUT -p tcp -m tcp --dport 9001 -j ACCEPT
sudo ip6tables -A INPUT -p tcp -m tcp --dport 51820 -j ACCEPT

sudo ip6tables -P INPUT DROP
sudo ip6tables -P INPUT DROP

sudo iptables-save | sudo tee /etc/iptables/rules.v4
sudo ip6tables-save | sudo tee /etc/iptables/rules.v6
