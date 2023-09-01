#!/usr/bin/env bash

function main {
    # Ubuntu 22.04

    sudo apt update

    # install nvidia driver
    driver=$(nvidia-detector)
    sudo apt install $driver
    # install util package for a particular nvidia device
    util=${driver/driver/utils}
    sudo apt install $util

    # sudo apt install build-essential

    # sudo apt install nvidia-cuda-toolkit nvidia-cuda-toolkit-gcc

    # nvcc --version

    sudo apt install make libssl-dev zlib1g-dev \
         libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
         libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
         libffi-dev liblzma-dev

    # install pyenv
    curl https://pyenv.run | bash

    # add the following in the bash shell
    # export PYENV_ROOT="$HOME/.pyenv"
    # command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    # eval "$(pyenv init -)"

    # pyenv install 3.9.6
    # pyenv global 3.9.6
}

main

