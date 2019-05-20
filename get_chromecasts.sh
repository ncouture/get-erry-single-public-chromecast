#!/bin/bash                                                                                                                                                                                                          #

if [[ $# -ne 2 ]]; then
    echo "Usage: "
    echo -e "\t$(basename $0) <num-results> <filename>"
    exit 1
fi  # num-results is results from ZMAP--not--of chromecasts found from ZMAP results.

export results="$1"
export filename="$2"

function scan {
    zmap -p 8008 --max-results "$results" -o - 2> /dev/null
}
... 
function get_chromecast_scan_result {
    curl -s --max-time 5 -o /dev/null -w "%{http_code} %{remote_ip}\n" http://$1:8008
}

export SHELL=$(type -p bash)
export -f get_chromecast_scan_result
export -f scan

parallel --jobs 50 get_chromecast_scan_result :::: <(scan) | awk '/404/{ print $2 }'