#!/usr/bin/env bash
# ------------------------------------------ #
# File : check_backup_status.sh
# Author : Juri Calleri
# Email : juri@juricalleri.net
# Date : 10/06/2016
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
# This script will be used by Nagios to monitor the status of the log created by my other script
# " sambaBackup.sh ". That script will create a second log file inside /tmp/ with the 
# necessary information used by Nagios. I call it "email" but I leave Nagios doing the notification job. 
# ------------------------------------------ #
# Usage:
#
# $1 = /tmp/ LogFile (email)
# $2 = "error" found in the log

RES=$(head -1 $1)
EXTRA=$(tail -n +3 $1)
ERROR=$(grep -oh $2 $1)
WARNING=$(grep -oh $3 $1)

[[ -z ${ERROR} ]] && ERROR=$2
[[ -z ${WARNING} ]] && WARNING=$3

if [[ $(echo ${EXTRA} | egrep "$ERROR") ]]; then
  echo ${RES} "|" ${EXTRA}
  exit 2
elif [[ $(echo ${EXTRA} | egrep "$WARNING") ]]; then
  echo ${RES} "|" ${EXTRA}
  exit 1
else
  echo ${RES} "|" ${EXTRA}
  exit 0
fi
