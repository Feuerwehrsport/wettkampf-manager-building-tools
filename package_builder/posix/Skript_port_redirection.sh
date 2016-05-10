#!/bin/bash
set -eu

SU_COMMANDS=(gksu kdesu gnomesu kdesudo sudo)

if [[ $(netstat -tulen | grep  :80  | tr -s ' ' | cut -d ' ' -f 4 | grep ':80$' | wc -l) -ne 0 ]] ; then
  echo "Der Port 80 ist belegt:"
  netstat -tulpen | grep :80
  exit 1
fi

if [[ "$(whoami)" != root ]] ; then
  for SU_COMMAND in ${SU_COMMANDS[@]}; do
    if command -v $SU_COMMAND >/dev/null 2>&1 ; then
      $SU_COMMAND $0 $*
      exit
    fi
  done

  echo "Dieses Programm muss als Root ausgeführt werden, damit der Port 80 benutzt werden kann."
  exit 1
fi

iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 3000