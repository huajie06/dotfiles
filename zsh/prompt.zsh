autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{#7dcfff}(%b)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{#f7768e}(%b|%a)%f'

setopt prompt_subst

PROMPT='%F{#7aa2f7}%~%f${vcs_info_msg_0_} %F{#bb9af7}❯%f '
