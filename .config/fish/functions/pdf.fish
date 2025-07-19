function pdf
    if test -f $argv[1]; and string match -qr '\.pdf$' -- $argv[1]
        zathura $argv[1] &
    else
        echo "Not a PDF or file not found: $argv[1]"
        return 1
    end
end

