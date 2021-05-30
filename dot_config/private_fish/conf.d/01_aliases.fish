alias df="df -h"
alias du="du -hs"

if type cargo >/dev/null
    alias ca="cargo"
end

abbr -a gw "./gradlew"
abbr -a vmv "sudo modprobe -a vmw_vmci vmmon && sudo systemctl start vmware-networks.service vmware-usbarbitrator.service"
