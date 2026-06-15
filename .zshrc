# Primary interactive shell configuration.

case $- in
    *i*) ;;
    *) return ;;
esac

[ -r "$HOME/.shell_common" ] && . "$HOME/.shell_common"

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt inc_append_history
setopt share_history

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt interactive_comments
setopt prompt_subst

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
autoload -Uz compinit
compinit -C

autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' %F{4}git:%b%f'
zstyle ':vcs_info:git:*' actionformats ' %F{4}git:%b|%a%f'

precmd() {
    vcs_info
}

if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" ]]; then
    host_segment='%F{2}%n@%m%f:'
else
    host_segment=''
fi

PROMPT='${host_segment}%F{4}%~%f${vcs_info_msg_0_} %# '

bindkey -e
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
