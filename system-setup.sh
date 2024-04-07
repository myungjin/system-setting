#!/usr/bin/env bash

function config_ubuntu {
    sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
         libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
         libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git

    curl https://pyenv.run | bash

    if grep "PYENV_ROOT" ~/.bashrc; then
        echo "pyenv is already configured"
    else
        echo >> ~/.bashrc
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init -)"\nfi' >> ~/.bashrc
    fi

    pyenv install 3.10.14
    pyenv global 3.10.14

    # install python packages
    pip install python-lsp-server[all]
    pip install pyls-black pyls-isort pyls-mypy
    pip install future
    pip install autopep8
    pip install isort
    pip install ruamel.yaml
    pip install numpy
}

function config_archlinux {
    sudo pacman -S -y --needed gimp
    sudo pacman -S -y --needed ttf-fira-code cantarell-fonts ccls python-pip

    sudo pacman -S -y pyenv
    
    # install golang language server
    sudo pacman -S -y --needed gopls

    # install python packages
    sudo pacman -S -y --needed python-language-server
    sudo pacman -S -y --needed python-pyls-black
    # sudo pacman -S pyls-black pyls-isort pyls-mypy

    sudo pacman -S -y --needed python-mccabe
    sudo pacman -S -y --needed python-rope
    sudo pacman -S -y --needed python-pyflakes
    sudo pacman -S -y --needed flake8
    sudo pacman -S -y --needed python-pycodestyle
    sudo pacman -S -y --needed python-pylint
    sudo pacman -S -y --needed yapf
    sudo pacman -S -y --needed python-pydocstyle

    sudo pacman -S -y --needed python-future
    sudo pacman -S -y --needed python-isort
    sudo pacman -S -y --needed python-ruamel-yaml
    sudo pacman -S -y --needed python-numpy

    if grep "PYENV_ROOT" ~/.bashrc; then
        echo "pyenv is already configured"
    else
        echo >> ~/.bashrc
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init -)"\nfi' >> ~/.bashrc
    fi
}

function config_macos {
    brew install gnupg
    brew install go gopls
    brew install pyenv
    pyenv install 3.9.6
    pyenv global 3.9.6
    pyenv version

    eval "$(pyenv init -)"
    echo -e '\nif command -v pyenv 1>/dev/null 2>&1; then\n    eval "$(pyenv init -)"\nfi' >> ~/.bash_profile
    
    # install c++ language server
    brew install ccls

    # this is required for installing font-cantarell
    brew install svn
    # install fira and cantarell fonts
    brew tap homebrew/cask-fonts
    brew install --cask font-fira-code
    brew install --cask font-cantarell

    # install python packages
    pip install python-lsp-server[all]
    pip install pyls-black pyls-isort pyls-mypy
    pip install future
    pip install autopep8
    pip install isort
    pip install ruamel.yaml
    pip install numpy
}

function config_common {
    # config git
    git config --global alias.graph 'log --all --decorate --oneline --graph'
    git config --global core.editor "emacs"
}

function main {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        distribution=$(lsb_release -i)
        if [[ $distribution == *"Ubuntu"* ]]; then
            config_ubuntu
        elif [[ $distribution == *"Arch"* ]]; then
            config_archlinux
        else
            echo "$distribution not supported"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        config_macos
    else
	echo "$OSTYPE not supported"
	exit 1
    fi

    config_common
}

main
