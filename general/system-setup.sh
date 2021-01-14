#!/usr/bin/env bash

function config_linux {
    sudo pacman -S ttf-fira-code cantarell-fonts ccls python-pip
}

function config_macos {
    brew install pyenv
    pyenv install 3.9.1
    pyenv global 3.9.1
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
}

function config_common {
    # install python packages
    pip install python-language-server[all]
    pip install pyls-black pyls-isort pyls-mypy
    pip install future
    pip install autopep8
    pip install isort
    pip install ruamel.yaml
    pip install numpy

    # config git
    git config --global alias.graph 'log --all --decorate --oneline --graph'
    git config --global core.editor "emacs"
}

function main {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        config_linux
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        config_macos
    else
	echo "$OSTYPE not supported"
	exit 1
    fi

    config_common
}

main
