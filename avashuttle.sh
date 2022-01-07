#!/bin/bash

#Purpose: This shellscript is a wrapper to handle avashuttle written in Golang(just call sshuttle and answer password prompt)
#         Together with avashuttle(golang) and avashuttle.sh the scripts can answer password prompt automatically from remote host.
#         IF gnome-terminal is installed, each source subnet can be opened in their own terminal, so you can close them when needed.

print_help() {
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo "Usage: avashuttle.sh -rh|--rhost <remote_host> -ss|--subnets <source_subnets> -pw|--password <remoteuser_password>"
    echo "Usage Example: bash avashuttle.sh --rhost root@172.27.17.56 --subnets \"172.27.0.0/16,192.168.0.0/16\" --password \"100yard-\""
    echo "
            -rh| --rhost    ====> remote host to do the tunnel e.g root@10.10.10.20
            -ss| --subnets  ====> source subnets, where it requires the tunnel e.g 192.167.20.0/24 
                                  if more than source subnet is needed, then you can use ',' as separation 
                                  Example: --subnets \"192.167.20.0/24,192.167.21.0/24 or all traffic 0/0\"
                                  each subnet will be opened in different Terminal if gnome-terminal is installed
				  if you don't want to close them all then you can CTRL-C to close it on each terminal
            -pw| --password ====> remote user password, if not specified, default 100yard- will be used"
    echo "------------------------------------------------------------------------------------------------------------------------"
    exit 0
}
#https://cheatsheet.dennyzhang.com/cheatsheet-ssh-a4
#sshuttle -r kubo@10.92.21.17 30.0.0.0/16 192.168.111.0/24 192.168.150.0/24 192.167.0.0/24
#sshuttle -e "ssh -i id_rsa" -r victim_user@victim_host 172.168.1.0/24 ---> using ssh-key for passwordless
#sshuttle --dns --ssh-cmd 'ssh -i <key>' -r root@<pivot_machine> <target_lan_CIDR>
#sshuttle --dns -NHr username@sshserver 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16

for i in "$@"; do
    case $i in
    -rh | --rhost)
        if [ -n "$2" ]; then
            RHOST="$2"
            shift 2
            continue
        fi
        ;;
    -ss | --subnets)
        if [ -n "$2" ]; then
            SUBNETS="$2"
            shift 2
            continue
        fi
        ;;
    -pw | --password)
        if [ -n "$2" ]; then
            PASSWORD="$2"
            shift 2
            continue
        fi
        ;;
    -h | -\? | --help)
        print_help
        shift #
        ;;
    *)
        # unknown option
        ;;
    esac
done

if [[ $RHOST == "" || $SUBNETS == "" ]]; then
    print_help
    exit 1
fi
if [[ $PASSWORD == "" ]]; then
    printf "%s\n" "You did not specify password, default 100yard- password will be used!"
    PASSWORD="100yard-"
fi

d="$(date '+%Y-%m-%d %H:%M:%S')"
function log() {
    printf "[%s]: INFO: %s\n" "$d" "$1"
}

CheckOSType() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     machine=Linux;;
      Darwin*)    machine=Mac;;
      CYGWIN*)    machine=Cygwin;;
      MINGW*)     machine=MinGw;;
      *)          machine="UNKNOWN:${unameOut}"
  esac
  #echo ${machine}
}

CheckFileExisted() {
    if [[ ! -f $1 ]]; then
        printf "[%s]: ERROR: %s: %s\n" "$d" "$1 is not existed!"
        exit 1
    else
        printf "[%s]: INFO: The following file %s is existed\n" "$d" "$1"
    fi
}

function CheckSetFilesPermission() {
printf "[%s]: INFO: %s\n" "$d" "Checking/Set avashuttle and avashuttle.sh scripts permission"
for file in avashuttle avashuttle.sh ; do
    l_perm=`stat -c '%a' "$file"`
    if [ "$l_perm" -ne "777" ] ; then
       chmod 777 "$file"
    fi
done

}
#check if user not login as root since only support root user due to additional prompt for non-root#
if [[ ! "$(whoami)" == "root" ]]; then 
     printf "[%s]: ERROR: %s\n" "$d" "You are not login as root, it does not supported!!"
     exit 1
fi

#check avashuttle expect in golang#
CheckFileExisted "./avashuttle"

#check if sshuttle is installed#
IsShuttle=$(which sshuttle)
CheckFileExisted "$IsShuttle"

#Check Operating System Type 
CheckOSType
printf "[%s]: INFO: Your Operating System Type: \n" "$d" "$machine"

#Check if gnome-terminal is installed or not#
if [[ "$machine" =~ "Linux" ]]; then
     IsGnomeTerminal=$(ps -e | grep -E -i "gnome-terminal" | awk '{ print $NF }')
elif [[ "$machine" =~ "Darvin" ]]; then
     IsGnomeTerminal="MacOS"
fi

#Check scripts file permission and set them#
if [[ "$machine" =~ "Linux" ]]; then
      CheckSetFilesPermission
else
      chmod 777 avashuttle avashuttle.sh
fi

#replace ',' with space for subnets argument as sshuttle required#
SUBNETS=$(echo ${SUBNETS} | sed 's/,/ /g')

if [[ "$IsGnomeTerminal" =~ "gnome" && "$machine" =~ "Linux" ]]; then
    readarray -t sarr_subnets <<<"$(echo $SUBNETS | tr -s ' ' '\012')"
    for src in "${!sarr_subnets[@]}"; do
        log "Start the tunnel for following source subnet: ${sarr_subnets[$src]}"
        #start sshuttle source subnet in each shell terminal if gnome-terminal is installed#
        Sshuttle=$(echo "./avashuttle --rhost ${RHOST} --password ${PASSWORD} --subnets=${sarr_subnets[$src]}")
        gnome-terminal -q --title=${sarr_subnets[$src]} -- ${Sshuttle}
    done
else #start original sshuttle multiple subnets option in one Terminal#
    log "Start the tunnel for following source subnet: ${SUBNETS}"
    ./avashuttle --rhost ${RHOST} --password ${PASSWORD} --subnets=${SUBNETS}
fi
