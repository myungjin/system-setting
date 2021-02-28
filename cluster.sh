#!/usr/bin/env bash

QEMU_URI=qemu:///system
TARGET_DIR=/var/lib/libvirt/images
BASE_IMAGE=ubuntu-20.04-server-cloudimg-amd64.img
BASE_IMAGE_URL=https://cloud-images.ubuntu.com/releases/focal/release/$BASE_IMAGE
OS_TYPE=linux
OS_VARIANT=ubuntu20.04
CONFIG_ISO=config.iso

PUB_KEY=$(cat ~/.ssh/id_ed25519.pub)
USER=k8s

NO_CLUSTERS=2
NO_NODES=1

function download_image {
    if [ ! -f "$TARGET_DIR/$BASE_IMAGE" ]; then
	echo $TARGET_DIR/$BASE_IMAGE 'does not exist'
	echo 'Downloading' $BASE_IMAGE
	sudo curl $BASE_IMAGE_URL -o $TARGET_DIR/$BASE_IMAGE
    fi
}

function check_vm {
    VM_NAME=$1

    RUNNING=$(virsh --connect $QEMU_URI list --name --state-running | grep -w $VM_NAME)
    if [ "$RUNNING" == "$VM_NAME" ]; then
	true
    else
	false
    fi
}

function eject_cdrom {
    VM_NAME=$1

    echo 'Ejecting and deleting' $TARGET_DIR/$VM_NAME-$CONFIG_ISO
    virsh --connect $QEMU_URI change-media $VM_NAME $TARGET_DIR/$VM_NAME-$CONFIG_ISO --eject --config
    sudo rm -f $TARGET_DIR/$VM_NAME-$CONFIG_ISO
}

function config {
    VM_NAME=$1

    cat >meta-data <<EOF
local-hostname: $VM_NAME
EOF

    cat >user-data <<EOF
#cloud-config
apt_upgrade: true

users:
  - name: $USER
    ssh-authorized-keys:
      - $PUB_KEY
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash

packages:
  - apt-transport-https
  - ca-certificates 
  - curl
  - gnupg-agent
  - software-properties-common

runcmd:
  - echo "AllowUsers $USER" >> /etc/ssh/sshd_config
  - restart ssh
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  - apt-key fingerprint 0EBFCD88
  - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable"
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io
EOF

    sudo genisoimage -output $TARGET_DIR/$VM_NAME-$CONFIG_ISO \
    	 -volid cidata -joliet -rock user-data meta-data

    rm -f user-data meta-data
}

function prepare_image {
    IMAGE=$1

    DISK_QUOTA=32G
    
    sudo cp -f $TARGET_DIR/$BASE_IMAGE $TARGET_DIR/$IMAGE
    sudo qemu-img resize -f qcow2 $TARGET_DIR/$IMAGE $DISK_QUOTA
}

function launch_vm {
    VM_NAME=$1
    IMAGE=$2

    VCPUS=$3
    MEMORY=$4

    sudo virt-install --connect $QEMU_URI \
	 --name $VM_NAME \
	 --vcpus $VCPUS \
	 --memory $MEMORY \
	 --disk path=$TARGET_DIR/$IMAGE,device=disk,bus=virtio \
	 --disk path=$TARGET_DIR/$VM_NAME-$CONFIG_ISO,device=cdrom \
	 --os-type $OS_TYPE \
	 --os-variant $OS_VARIANT \
	 --virt-type kvm \
	 --network network=default,model=virtio \
	 --graphics none \
	 --autoconsole none \
	 --import
}

function create_rancher {
    VM_NAME=rancher
    IMAGE=$VM_NAME.qcow2

    if check_vm $VM_NAME; then
	eject_cdrom $VM_NAME
    else
	echo 'Creating' $VM_NAME
	config $VM_NAME
	prepare_image $IMAGE
	launch_vm $VM_NAME $IMAGE 1 2048
    fi
}

function create_masters {
    NO_CLUSTERS=$1

    for cidx in $(seq 1 $NO_CLUSTERS); do
	VM_NAME=$(printf "k8s-master%02d" $cidx)
	IMAGE=$VM_NAME.qcow2

	if check_vm $VM_NAME; then
	    eject_cdrom $VM_NAME
	else
	    echo 'Creating' $VM_NAME
	    config $VM_NAME
	    prepare_image $IMAGE
	    launch_vm $VM_NAME $IMAGE 1 2048
	fi
    done
}

function create_workers {
    NO_CLUSTERS=$1
    NO_NODES=$2

    for cidx in $(seq 1 $NO_CLUSTERS); do
	for nidx in $(seq 1 $NO_NODES); do
	    VM_NAME=$(printf "worker%02d-%02d" $cidx $nidx)
	    IMAGE=$VM_NAME.qcow2


	    if check_vm $VM_NAME; then
		eject_cdrom $VM_NAME
	    else
		echo 'Creating' $VM_NAME
		config $VM_NAME
		prepare_image $IMAGE
		launch_vm $VM_NAME $IMAGE 2 2048
	    fi
	done
    done
}

function create_clusters {
    create_rancher
    create_masters $NO_CLUSTERS
    create_workers $NO_CLUSTERS $NO_NODES
}

function main {
    download_image
    create_clusters
}

main
