#!/usr/bin/env bash

function config_linux {
    echo "Do nothing"
}

function config_macos {
    # install c++ language server
    brew install ccls

    # install fira font
    brew tap homebrew/cask-fonts
    brew install --cask font-fira-code
}

function config_common {
    # install python packages
    pip install python-language-server[all]
    pip install pyls-black pyls-isort pyls-mypy
    pip install future

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
