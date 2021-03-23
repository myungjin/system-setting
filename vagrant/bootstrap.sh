#! /usr/bin/env bash

function install_packages {
    sudo apt update
    sudo apt upgrade -y

    ERLANG_GPG_KEY=https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
    wget -O- $ERLANG_GPG_KEY | sudo apt-key add -
    echo "deb https://packages.erlang-solutions.com/ubuntu focal contrib" | \
	sudo tee /etc/apt/sources.list.d/rabbitmq.list

    sudo apt update

    sudo apt install -y build-essential erlang libsnappy-dev libssl-dev \
	 net-tools python3-pip python3-matplotlib python3-testresources

    sudo apt clean
}

function install_ml_libraries {
    pip3 install --upgrade pip

    PIP3=$HOME/.local/bin/pip3

    $PIP3 install torch==1.8.0+cpu torchvision==0.9.0+cpu torchaudio==0.8.0 \
	  -f https://download.pytorch.org/whl/torch_stable.html

    $PIP3 install tensorflow
    $PIP3 install keras

    $PIP3 cache purge
}

function install_vernemq {
    PROG=vernemq
    VERSION=1.11.0

    cd /tmp
    if [ ! -d $PROG ]; then
	git clone https://github.com/$PROG/$PROG.git
    fi

    # compile
    cd $PROG
    git checkout tags/$VERSION
    make rel

    # install
    sudo cp -rf _build/default/rel/$PROG /

    # delete source code
    cd /
    rm -rf /tmp/$PROG

    # create systemd unit file
    sudo bash -c 'cat <<EOF > /lib/systemd/system/vernemq.service
# systemd unit file
[Unit]
Description=VerneMQ Server
After=network.target epmd@0.0.0.0.socket
Wants=network.target epmd@0.0.0.0.socket

[Service]
Type=forking
PIDFile=/run/vernemq/vernemq.pid
User=vernemq
Group=vernemq
NotifyAccess=all
LimitNOFILE=infinity
Environment="WAIT_FOR_ERLANG=3600"
TimeoutStartSec=3600
RuntimeDirectory=vernemq
WorkingDirectory=/vernemq
ExecStartPre=/vernemq/bin/vernemq chkconfig
ExecStart=/vernemq/bin/vernemq start
ExecStop=/vernemq/bin/vernemq stop
ExecStop=/bin/sh -c "while ps -p \$MAINPID >/dev/null 2>&1; do sleep 1; done"

[Install]
WantedBy=multi-user.target
EOF'

    # post install configuration
    HOME_DIR=/$PROG

    # create group
    if ! getent group $PROG >/dev/null; then
	sudo addgroup --system $PROG
    fi

    # create user
    if ! getent passwd $PROG >/dev/null; then
	sudo adduser --ingroup $PROG \
	     --home $HOME_DIR \
	     --disabled-password \
	     --system --shell /bin/bash --no-create-home \
	     --gecos "VerneMQ broker" $PROG
    fi

    sudo chown -R $PROG:$PROG $HOME_DIR
}

function config_user {
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

function main {
    install_packages
    install_ml_libraries
    install_vernemq
    config_user
}

main
