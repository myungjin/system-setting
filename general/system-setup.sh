#!/usr/bin/env bash

function config_linux {
    echo "Do nothing"
}

function config_macos {
    # install c++ language server
    brew install ccls

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
