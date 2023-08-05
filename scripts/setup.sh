#!/usr/bin/env sh
export DEBIAN_FRONTEND=noninteractive

DEF_USER=martin
DEF_HOME=/home/$DEF_USER

# Timezone
sudo timedatectl set-timezone Europe/Berlin

# APT
sudo apt-get update
sudo apt-get install git wget htop ca-certificates curl gnupg rsync tree ntp tmux iptables iptables-persistent -y

# Passwordless sudo
echo "$DEF_USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$DEF_USER

# Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo useradd worker -u 2000
sudo usermod -aG docker $DEF_USER
sudo usermod -aG docker worker
sudo mkdir /var/docker
sudo chown -R worker:docker /var/docker
sudo chmod -R g+ws /var/docker

# Add basic firewall exceptions
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p icmp -j ACCEPT
sudo iptables -A OUTPUT -p icmp -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
sudo iptables -A OUTPUT -p tcp -m tcp --dport 22 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
sudo iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 853 -m state --state NEW -j ACCEPT
sudo iptables -A OUTPUT -p udp --dport 853 -m state --state NEW -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
sudo iptables-save > /etc/iptables/rules.v6

# Add dotfiles
mkdir -p $DEF_HOME
sudo mv /root/.ssh/authorized_keys $DEF_HOME.ssh/authorized_keys
git clone --bare https://github.com/dulli/dotfiles.git $DEF_HOME/.dotfiles
sudo chown -R $DEF_USER:$DEF_USER $DEF_HOME/.dotfiles
git --git-dir=$DEF_HOME/.dotfiles/ --work-tree=$DEF_HOME checkout -f
