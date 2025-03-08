function mc --description "Create a directory and cd into it (mkdir + cd)"
    # Check if a directory name is provided
    if test (count $argv) -eq 0
	echo "Create a directory and cd into it"
        echo "Usage: mc <directory_name>"
        return 1
    end

    # Create the directory and cd into it
    mkdir -p $argv[1] && cd $argv[1]
end

