
function fish_prompt
    # Get only the last directory component (basename)
    set -l current_dir (path basename $PWD)

    # Print the current directory in cyan, followed by a green arrow
    set_color cyan
    echo -n $current_dir
    set_color green
    echo -n " > "
    set_color normal
end

