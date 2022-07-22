#!/usr/bin/env bash

function config_linux {
    sudo pacman -S ttf-fira-code cantarell-fonts ccls python-pip

    # install python packages
    sudo pacman -S python-language-server
    sudo pacman -S python-pyls-black
    # sudo pacman -S pyls-black pyls-isort pyls-mypy

    sudo pacman -S python-mccabe
    sudo pacman -S python-rope
    sudo pacman -S python-pyflakes
    sudo pacman -S flake8
    sudo pacman -S python-pycodestyle
    sudo pacman -S python-pylint
    sudo pacman -S yapf
    sudo pacman -S python-pydocstyle

    sudo pacman -S python-future
    sudo pacman -S python-isort
    sudo pacman -S python-ruamel-yaml
    sudo pacman -S python-numpy
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
