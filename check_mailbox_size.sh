#!/usr/bin/env bash
#
# ------------------------------------------ #
# File : check_mailbox_size
# Author : Juri Calleri
# Email : juri@juricalleri.net
# Date : 27/04/2016
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
# A way to manage the problems related to the mailbox when it is full, on a Ubuntu system.
# I match the mailbox_size_limit in /etc/postfix/main.cf with the current size of the mailbox.
# When the mailbox is close to be full, this script will empty it. Supports Performance Data.
# ------------------------------------------ #
# Usage: 
# 1. 
#    Edit sudoers (visudo) and add:
#    nrpe ALL=(ALL:ALL) NOPASSWD: /usr/local/nagios/libexec/check_mailbox_size.sh
#    where nrpe is the user running nrpe/nagios
# 2. 
#    Add to nrpe.cfg:
#    command[check_mailbox_size]=sudo /usr/local/nagios/libexec/check_mailbox_size.sh mailboxName
# 3.
#    chown nrpe:nrpe /usr/local/nagios/libexec/check_mailbox_size.sh
#    chmod ug=rwx,o= /usr/local/nagios/libexec/check_mailbox_size.sh
# ------------------------------------------ #
# Nagios/Unix Exit codes
# OK=0
# WARNING=1
# CRITICAL=2
# UNKNOWN=3

MAILBOX="/var/mail/$1"
MGOOD=471859200 #450MB
TODAY=$(date "+%F")
MSIZE=$(wc -c <"$MAILBOX")

convert() { numfmt --to=iec --suffix=B "$@"; }
if [ $MSIZE -gt 1048576 ]; then #if bigger than 1MB in Byte
  MSIZE=$(convert $(wc -c <"$MAILBOX") | awk -F"MB" '{print $1}')
  MGOOD=450.0
fi
MDIM=$(convert $(grep "mailbox_size_limit" /etc/postfix/main.cf | awk -F" " '{print $3}'))

if [ ! -f $MAILBOX ]; then
  echo "Can't check the size of $MAILBOX | Size=0; Total=$MDIM"
  exit 3
else
  if [ 1 -eq "$(echo "${MSIZE} < ${MGOOD}" | bc)" ]; then
    echo "Size of $1 is $MSIZE | Size=$MSIZE; Total=$MDIM"
    exit 0
  fi
  if [ 1 -eq "$(echo "${MSIZE} > ${MGOOD}" | bc)" ]; then
	service postfix stop
	sleep 2
    cp $MAILBOX $MAILBOX.$TODAY
    > $MAILBOX
	service postfix start
    if [ $? -eq 0 ]; then
      NSIZE=$(convert $(wc -c <"$MAILBOX"))
      echo "Mailbox updated. Size of $1 is $NSIZE | Size=$NSIZE; Total=$MDIM"
      exit 0
    else
      echo "Couldn't create a backup for $1. Size of $1 is $MSIZE | Size=$MSIZE; Total=$MDIM"
      exit 2
    fi
  fi
#  if [ 1 -eq "$(echo "${MSIZE} > ${MDIM}" | bc)" ]; then
#    echo "Size of $1 is $MSIZE | Size=$MSIZE; Total=$MDIM"
#    exit 2
#  fi
fi
