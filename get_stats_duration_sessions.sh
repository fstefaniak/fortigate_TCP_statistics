#!/bin/bash
# $1 [needed] path for logs (ex: "/mnt/path/to/fortigate/log/folder" )
# $2 $3 ... [needed] IP of destination

#find folder where is this script
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do
 DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
 SOURCE=$(readlink "$SOURCE")
 [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE
done
script_dir=$DIR

#verify ip validity
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if [ $# -lt 2 ] ; then
    echo "Error: no enough arguments: \$1 -> need path for log ; \$2 or more -> for IP of destination" >&2
    exit 1
else
    if [ -z "$1" ] ; then
        echo 'Error: incorrect path (null)' >&2
        exit 1
    else
        if [[ -d "$1" && ! -L "$1" ]] ; then
            log_path="$1"
        else
            echo "Error: incorrect path (it's not a folder)" >&2
            exit 1
        fi
    fi
    nb_IP=0
    declare -a IP
    args=("$@")
    #delete path
    unset 'args[0]'
    for i in "${args[@]}"; do
        if [ -z "$i" ] ; then
            echo "Warning: incorrect IP (null)" >&2
        else
            if valid_ip "$i" ; then
                ((nb_IP++))
                IP[${#IP[@]}]=$i
            else
                echo "Warning: $i is not a correct IP" >&2
            fi
        fi
    done
    if [ "$nb_IP" -lt 1 ] ; then
        echo "Error: no valid IP set" >&2
        exit 1
    fi
    echo "IP: " "${IP[@]}";
fi

#lists log files
cd "$log_path" || exit 1
nb_logs=$(find . -maxdepth 1 -name '*.log' |wc -l)
if [ "$nb_logs" -lt 1 ] ; then
    echo "no *.log detected in path $1" >&2
    exit 1
else
    echo "$nb_logs logs files detected:"
    find . -maxdepth 1 -name '*.log'
    declare -a Logs
    for i in $(seq 1 "$nb_logs"); do
        Logs[${#Logs[@]}]=$(find . -maxdepth 1 -name '*.log'|cut -d$'\n' -f"$i")
    done
fi
#echo "#Logs: ${#Logs[@]} Logs: ${Logs[@]}";

json="{\n"
#make stats
for ip in "${IP[@]}"; do
    json+="\t\"$ip\": {\n"
    for log in "${Logs[@]}"; do
     grep "$ip" "$log" |grep 'traffic' |grep 'action="close"' | grep sessionid  |awk -F ' ' '{ print $35}' |grep duration |awk -F '=' '{print $2}' > "$script_dir"/data.txt
     test="$(head "$script_dir"/data.txt -n 10 |wc -l)"
     if [ "$test" -gt 2 ] ; then
        stats=$(ministat -n "$script_dir"/data.txt |grep -v stdin |grep -v Max |grep -v '.txt')
        N=$(echo "$stats" |awk '{print $2}')
        Min=$(echo "$stats" |awk '{print $3}')
        Max=$(echo "$stats" |awk '{print $4}')
        Med=$(echo "$stats" |awk '{print $5}')
        Moy=$(echo "$stats" |awk '{print $6}')
        Ecart=$(echo "$stats" |awk '{print $7}')
        echo "$ip / $log: {\"N\": $N, \"Min\": $Min, \"Max\": $Max, \"Med\": $Med, \"Moy\": $Moy, \"Ecart\": $Ecart}"
        json+="\t\t\"$log\": {\"N\": $N, \"Min\": $Min, \"Max\": $Max, \"Med\": $Med, \"Moy\": $Moy, \"Ecart\": $Ecart},\n"
      else
        echo "$ip / $log: not enough data ($test)"
        #json+="\t\t\"$log\": \"not enough data ($test)\",\n"
      fi      
    done
    json="${json::-3}"
    json+="\n\t},\n"
done
json="${json::-3}"
json+="\n}"

cd "$script_dir" || exit 1
rm data.txt
echo -e "$json" > results_duration.json
