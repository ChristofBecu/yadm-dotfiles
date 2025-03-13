function fish_right_prompt
    set -l cmd_status $status
    if test $cmd_status -ne 0
        echo -n (set_color red)"✘ $cmd_status"
    end

    function __show_git_status
        set -l repo_name $argv[1]
        set -l git_cmd $argv[2]
        

        set -l git_dir (eval $git_cmd rev-parse --git-dir 2>/dev/null)

        if test -z "$git_dir"
            return
        end

        set -l branch (eval $git_cmd symbolic-ref --short HEAD 2>/dev/null)
        set -l commit (eval $git_cmd rev-parse HEAD 2>/dev/null | string sub -l 7)
        set -l action (fish_print_git_action "$git_dir")

        # Get the commit difference counts between local and remote.
        eval $git_cmd rev-list --count --left-right 'HEAD...@{upstream}' 2>/dev/null |
            read -d \t -l status_ahead status_behind
        if test $status -ne 0
            set status_ahead 0
            set status_behind 0
        end

        # Get stash status
        set -l status_stashed 0
        if test -f "$git_dir/refs/stash"
            set status_stashed 1
        end

        # Get working directory status
        set -l porcelain_status (eval $git_cmd status --porcelain 2>/dev/null | string sub -l2)

        set -l status_added 0
        if string match -qr '[ACDMT][ MT]|[ACMT]D' $porcelain_status
            set status_added 1
        end
        set -l status_deleted 0
        if string match -qr '[ ACMRT]D' $porcelain_status
            set status_deleted 1
        end
        set -l status_modified 0
        if string match -qr '[MT]$' $porcelain_status
            set status_modified 1
        end
        set -l status_renamed 0
        if string match -qe R $porcelain_status
            set status_renamed 1
        end
        set -l status_unmerged 0
        if string match -qr 'AA|DD|U' $porcelain_status
            set status_unmerged 1
        end
        set -l status_untracked 0
        if string match -qe '\?\?' $porcelain_status
            set status_untracked 1
        end

        if test "$repo_name" = "git (root)"
            set_color --background=red white
        else
            set_color -o
        end

        echo -n " ($repo_name)"
        if test -n "$branch"
            set_color green
            echo -n " $branch"
        end
        if test -n "$commit"
            echo -n ' '(set_color yellow)"$commit"
        end
        if test -n "$action"
            set_color normal
            echo -n (set_color white)':'(set_color -o brred)"$action"
        end
        if test $status_ahead -ne 0
            echo -n ' '(set_color brmagenta)'⬆'
        end
        if test $status_behind -ne 0
            echo -n ' '(set_color brmagenta)'⬇'
        end
        if test $status_stashed -ne 0
            echo -n ' '(set_color cyan)'✭'
        end
        if test $status_added -ne 0
            echo -n ' '(set_color green)'✚'
        end
        if test $status_deleted -ne 0
            echo -n ' '(set_color red)'✖'
        end
        if test $status_modified -ne 0
            echo -n ' '(set_color blue)'✱'
        end
        if test $status_renamed -ne 0
            echo -n ' '(set_color magenta)'➜'
        end
        if test $status_unmerged -ne 0
            echo -n ' '(set_color yellow)'═'
        end
        if test $status_untracked -ne 0
            echo -n ' '(set_color white)'◼'
        end

        set_color normal
    end

    set -l current_dir (pwd)

    if test "$current_dir" = "$HOME"
        if command -sq yadm
            __show_git_status "yadm" "yadm"
        end
    else if test "$current_dir" = "/etc"
        if command -sq sudo
            __show_git_status "git (root)" "sudo git"
        end
    else
        if command -sq git
            __show_git_status "git" "git"
        end
    end

    set_color normal
end
