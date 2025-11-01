function release_port
    # $argv[1] = port number
    set port $argv[1]

    if test -z "$port"
        echo "Usage: release_port <port>"
        return 1
    end

    # Get PIDs listening on the given port
    set pids (lsof -t -iTCP:$port -sTCP:LISTEN)

    if test -z "$pids"
        echo "Port $port is not busy."
        return 0
    end

    # Kill the processes and report
    echo $pids | xargs -r kill
    and echo "Port $port released (PID(s) $pids killed)."
end
