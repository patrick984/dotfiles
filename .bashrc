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

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\eOA": history-search-backward'
bind '"\eOB": history-search-forward'

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

__git_prompt_segment() {
    __git_segment=''
    command -v git >/dev/null 2>&1 || return

    local status first rest branch color line
    status="$(git status --porcelain=v1 --branch 2>/dev/null)" || return
    first="${status%%$'\n'*}"
    rest="${status#"$first"}"
    branch="${first#'## '}"
    branch="${branch%%...*}"
    branch="${branch%% \[*}"

    if [ "$branch" = "HEAD (no branch)" ] || [ -z "$branch" ]; then
        branch="$(git rev-parse --short HEAD 2>/dev/null)" || return
    fi

    branch="${branch//\\/\\\\}"
    branch="${branch//\$/\\$}"
    branch="${branch//\`/\\\`}"

    color='\[\033[01;32m\]'
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        color='\[\033[38;5;130m\]'
        case "$line" in
            DD*|AU*|UD*|UA*|DU*|AA*|UU*)
                color='\[\033[01;31m\]'
                break
                ;;
        esac
    done <<EOF
$rest
EOF

    __git_segment=" ${color}${branch}\[\033[00m\]"
}

if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ]; then
    __host='\[\033[01;32m\]\u@\h\[\033[00m\]:'
else
    __host=''
fi

__set_prompt() {
    local last_status=$?
    local title=''

    __git_prompt_segment

    case "$TERM" in
        xterm*|rxvt*)
            title='\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]'
            ;;
    esac

    PS1="${title}"'${debian_chroot:+($debian_chroot)}'"$__host"'\[\033[01;34m\]\w\[\033[00m\]'"$__git_segment"' \$ '
    return "$last_status"
}

PROMPT_COMMAND=__set_prompt

if ! shopt -oq posix; then
    if [ -r /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -r /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

[ -r "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"
