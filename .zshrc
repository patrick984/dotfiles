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

git_prompt_segment=''

precmd() {
    git_prompt_segment=''
    command -v git >/dev/null 2>&1 || return

    local git_status first rest branch color line
    git_status="$(git status --porcelain=v1 --branch 2>/dev/null)" || return
    first="${git_status%%$'\n'*}"
    rest="${git_status#"$first"}"
    branch="${first#'## '}"
    branch="${branch%%...*}"
    branch="${branch%% \[*}"

    if [[ "$branch" == "HEAD (no branch)" || -z "$branch" ]]; then
        branch="$(git rev-parse --short HEAD 2>/dev/null)" || return
    fi

    color='%F{2}'
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        color='%F{130}'
        case "$line" in
            DD*|AU*|UD*|UA*|DU*|AA*|UU*)
                color='%F{1}'
                break
                ;;
        esac
    done <<< "$rest"

    git_prompt_segment=" ${color}${branch}%f"
}

if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" ]]; then
    host_segment='%F{2}%n@%m%f:'
else
    host_segment=''
fi

PROMPT='${host_segment}%F{4}%~%f${git_prompt_segment} %# '

bindkey -e
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
