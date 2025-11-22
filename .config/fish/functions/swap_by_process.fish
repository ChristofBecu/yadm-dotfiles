#!/usr/bin/env fish

# This script lists all running processes that are using swap memory.
# It displays the PID, the amount of swap used (in kB), and the command name.
# The output is sorted in descending order by swap usage.
# Useful for identifying which processes are consuming the most swap on the system.

printf "%-8s %12s %s
" PID "SWAP (kB)" COMMAND
for pid in (ps -e -o pid=)
    if test -f /proc/$pid/status
        set swap (awk '/VmSwap/ {print $2}' /proc/$pid/status)
        if test $swap -gt 0
            set cmd (cat /proc/$pid/comm)
            printf "%-8s %12s %s
" $pid $swap $cmd
        end
    end
end | sort -k2 -nr
