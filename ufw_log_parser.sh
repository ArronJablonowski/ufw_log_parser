#!/bin/bash
# Usage: 
#   ./ufw_log_parser.sh | tail -n 30 
#   watch -n 2 "./ufw_log_monitor.sh | tail -n 30 "

#ufw log file 
infile=/var/log/ufw.log
# local host name ( Unused currently ) 
# localHostName=$( hostname )


#sort log file 
while read line; do
    logtime=$(echo $line | cut -c 1-15 ) 
    if [[ $line == *"UFW BLOCK"* ]]; then 
        case $line in
        *"DPT"*)
            ip="${line##*SRC=}"
            ip="${ip%% *}"
            dst="${line##*DST=}"
            dst="${dst%% *}"
            port="${line##*DPT=}"
            port="$dst:${port%% *}"
            proto="${line##*PROTO=}"
            proto="${proto%% *}"
            mac="${line##*MAC=}"
            mac="${mac%% *}"
            macAdd="src: $(echo $mac | cut -d ':' -f7,8,9,10,11,12)"  
            if [[ -z "${mac// }" ]]; then 
                macAdd='src: unknown mac addr ' 
            fi 
            echo "[ $logtime ] [!BLOCK!] [ $macAdd $ip --X $port $proto ]" 
            ;;
        *"DST"*)
            ip="${line##*SRC=}"
            ip="${ip%% *}"
            dst="${line##*DST=}"
            dst="${dst%% *}"
            proto="${line##*PROTO=}"
            proto="${proto%% *}"
            mac="${line##*MAC=}"
            mac="${mac%% *}"
            macAdd="[Source MAC: $(echo $mac | cut -d ':' -f7,8,9,10,11,12)]"
            echo "[ $logtime ] $macAdd mDNS:$ip ->X $dst"
            ;;    
        esac
    
    elif [[ $line == *"UFW ALLOW"* ]]; then
        case $line in
        *"DPT"*)
            ip="${line##*SRC=}"
            ip="${ip%% *}"
            dst="${line##*DST=}"
            dst="${dst%% *}"
            port="${line##*DPT=}"
            port="$dst:${port%% *}"
            proto="${line##*PROTO=}"
            proto="${proto%% *}"
            mac="${line##*MAC=}"
            mac="${mac%% *}"
            macAdd="src: $(echo $mac | cut -d ':' -f7,8,9,10,11,12)"  
            if [[ "${#macAdd}" -le 17  ]]; then 
                macAdd='src: lo:ca:lh:os:t    ' 
            fi 
            echo "[ $logtime ] [ allow ] [ $macAdd $ip --> $port $proto ]" 
            ;;   
        esac
    fi
done <  "$infile"
