function rmbak {
    find . -type f -name '*~' -delete

    yapf_files=$(find . -type f -name 'yapf[^_]*.py' 2> /dev/null | grep -v site-packages)
    for file in $yapf_files; do
	rm -f $file
    done
}

function addsudo {
    username=$1
    exists=`id $username`
    if [[ -z $exists ]]; then
         return
    fi

    echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$username
}

function parse_git_branch {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ "

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
