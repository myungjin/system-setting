# Function which adds an alias to the current shell and to
# the ~/.bash_aliases file.

########## aliasing. #########
alias texclean='command rm -f *.toc *.aux *.log *.cp *.fn *.tp *.vr *.pg *.ky'
alias grep='grep --color'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'
alias h='history'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias l='ls --color=auto'
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    alias l='ls -CFG'
    alias ls='ls -G'
    alias ll='ls -alFG'
    alias dir='ls -alG'
else
    alias l='ls -CF'
    alias ls='ls'
    alias ll='ls -alF'
    alias dir='ls -al'
fi

# only for linux machine
# alias nt='nautilus'

# ~/.bash_aliases ends here
