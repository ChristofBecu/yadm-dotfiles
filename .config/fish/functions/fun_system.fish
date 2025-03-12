function suspend --description "Suspend the system"
    systemctl suspend
end

function hibernate --description "Hibernate the system"
    systemctl hibernate
end

function reboot --description "Reboot the system"
    systemctl reboot
end

function poweroff --description "Power off the system"
    systemctl poweroff
end

function shutdown --description "Shutdown the system"
    systemctl shutdown
end

function lock --description "Lock the screen"
    loginctl lock-session
end

function logout --description "Logout the current user"
    loginctl terminate-session $XDG_SESSION_ID
end


