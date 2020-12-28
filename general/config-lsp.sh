#!/usr/bin/env bash

function config_linux {
    echo "Do nothing"
}

function config_macos {
    brew install ccls
}

function config_common {
    pip install python-language-server[all]
    pip install pyls-black pyls-isort pyls-mypy
    pip install future
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
