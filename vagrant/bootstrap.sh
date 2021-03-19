#! /usr/bin/env bash

function install_packages() {
    sudo apt update
    sudo apt upgrade -y

    ERLANG_GPG_KEY=https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
    wget -O- $ERLANG_GPG_KEY | sudo apt-key add -
    echo "deb https://packages.erlang-solutions.com/ubuntu focal contrib" | \
	sudo tee /etc/apt/sources.list.d/rabbitmq.list

    sudo apt update

    sudo apt install -y build-essential erlang libsnappy-dev libssl-dev net-tools

    sudo apt clean
}

function config_user() {
    USER=vagrant
    getent passwd $USER > /dev/null
    if [ $? -ne 0 ]; then
	# Add vagrant user
	sudo /usr/sbin/useradd $USER -g $USER -G wheel
	sudo echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER
	chmod 0440 /etc/sudoers.d/$USER
    fi

    # Installing vagrant keys
    mkdir -pm 700 /home/$USER/.ssh
    wget --no-check-certificate \
	 'https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub' \
	 -O /home/$USER/.ssh/authorized_keys
    
    chmod 0600 /home/$USER/.ssh/authorized_keys
    chown -R $USER /home/$USER/.ssh
}

function main() {
    install_packages
    config_user
}

main
