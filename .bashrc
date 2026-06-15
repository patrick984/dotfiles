# Bash interactive shell configuration.

case $- in
    *i*) ;;
    *) return ;;
esac

[ -r "$HOME/.shell_common" ] && . "$HOME/.shell_common"

HISTCONTROL=ignoreboth
HISTSIZE=50000
HISTFILESIZE=50000

shopt -s histappend
shopt -s checkwinsize
shopt -s cmdhist

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

__git_branch() {
    command -v git >/dev/null 2>&1 || return
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
    git branch --show-current 2>/dev/null | sed 's/^/ git:/'
}

if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ]; then
    __host='\[\033[01;32m\]\u@\h\[\033[00m\]:'
else
    __host=''
fi

PS1='${debian_chroot:+($debian_chroot)}'"$__host"'\[\033[01;34m\]\w\[\033[00m\]\[\033[01;34m\]$(__git_branch)\[\033[00m\] \$ '
unset __host

case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
esac

if ! shopt -oq posix; then
    if [ -r /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -r /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

[ -r "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"
