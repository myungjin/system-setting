#!/usr/bin/env bash


# This is for ubuntu 22.04

# references: https://medium.com/repro-repo/build-pytorch-from-source-with-cuda-12-2-1-with-ubuntu-22-04-b5b384b47ac
#             https://github.com/pytorch/pytorch/tree/v2.2.0?tab=readme-ov-file#install-pytorch

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

# doesn't seem necessary; magma-cuda122 doesn't exist in conda in pytorch channel,
# so we have to build it from the source if we want to use it.
# conda install -c pytorch magma-cuda122

# clone pytorch repo
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
# if you are updating an existing checkout
git submodule sync
git submodule update --init --recursive

# install requirements
pip install -r requirements.txt


# some additional configuration
ln -sf /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /home/myungjle/miniconda3/lib/libstdc++.so.6

# start build
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
export _GLIBCXX_USE_CXX11_ABI=1
USE_CUDA=1 python setup.py develop
# python setup.py develop
