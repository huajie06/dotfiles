set fish_greeting

if status is-interactive
    # Inherit PATH from bash login shell
    bash -l -c 'echo "$PATH"' 2>/dev/null | head -1 | read -l bash_path
    if test -n "$bash_path"
        set -gx PATH $bash_path
    end
end
