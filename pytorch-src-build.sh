#!/usr/bin/env bash


# This is for ubuntu 22.04

# install conda
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

hash=$(sha256sum Miniconda3-latest-Linux-x86_64.sh)
if [[ $hash != "c9ae82568e9665b1105117b4b1e499607d2a920f0aea6f94410e417a0eff1b9c" ]]; then
    echo "hash value mismatch"
    exit 1
fi

bash Miniconda3-latest-Linux-x86_64.sh

echo "export PATH=$HOME/miniconda3/bin:$PATH" >> ~/.bashrc

echo "Please run 'source ~/.bashrc'"

cuda_keyring_file=cuda-keyring_1.1-1_all.deb
# download keyring
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/$cuda_keyring_file
sudo dpkg -i $cuda_keyring_file
sudo apt update

# install cuda-toolkit
sudo apt -y install cuda-toolkit-12-2
# install cudnn
sudo apt-get -y install cudnn-cuda-12

# delete keyring file
rm -f $cuda_keyring_file

conda_env_name=pytorch-src-build
# set up conda environments
conda create -n $conda_env_name
conda activate $conda_env_name

conda install cmake ninja
conda install mkl mkl-include
conda install -c pytorch magma-cuda122

# clone pytorch repo
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
# if you are updating an existing checkout
git submodule sync
git submodule update --init --recursive

# install requirements
pip install -r requirements.txt

# start build
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
python setup.py develop
