#!/usr/bin/env bash
#
# ------------------------------------------ #
# File : read_last_line
# Author : Juri Calleri
# Email : juri@juricalleri.net
# Date : 03/05/2016
# ------------------------------------------ #
# This program is free software; you can redistribute it and/or modify it
# without even asking for permission, but please keep the author.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# ------------------------------------------ #
# What do I need this for?
# If you create your own log and the last line tells you whether your script failed or succeeded, 
# this script will match 2 words of your choice (best if OK : ERROR) with the last row of your log file.
# ------------------------------------------ #
# Usage: 
# 1. 
#    Add to nrpe.cfg:
#    command[read_last_line]=/usr/local/nagios/libexec/read_last_line.sh /var/log/mylog OK error
# 2.
#    chown nrpe:nrpe /usr/local/nagios/libexec/read_last_line.sh
#    where nrpe is the user:group running nrpe/nagios
#    chmod ug=rwx,o= /usr/local/nagios/libexec/read_last_line.sh
# ------------------------------------------ #
# Nagios/Unix Exit codes
# OK=0
# WARNING=1
# CRITICAL=2
# UNKNOWN=3

RES=$(tail -1 $1)
VAR2=$(grep -oh $2 $1 | tail -1)
VAR3=$(grep -oh $3 $1 | tail -1)

[[ -z ${VAR2} ]] && VAR2=$2
[[ -z ${VAR3} ]] && VAR3=$3

if [ ! -f $1 ]; then
  echo "Log file not found"
  exit 3
  # if $VAR2 exists
  if [[ $(echo ${RES} | egrep "$VAR2") ]]; then
    # and if $VAR3 does not exist
    if [[ ! $(echo ${RES} | egrep "$VAR3") ]]; then
      echo ${RES}
      exit 0
    # and if $VAR3 exists too
    elif [[ $(echo ${RES} | egrep "$VAR3") ]]; then
      echo ${RES}
      exit 1
    fi
  # else if $VAR2 does not exist
  else
    # and if $VAR3 does not exists
    if [[ ! $(echo ${RES} | egrep "$VAR3") ]]; then
      echo ${RES}
      exit 1
    # and if $VAR3 exists too
    elif [[ $(echo ${RES} | egrep "$VAR3") ]]; then
      echo ${RES}
      exit 2
    fi
  fi
fi
