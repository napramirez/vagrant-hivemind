#!/bin/bash
#

HOSTNAME=$*

if [ ! -f ~/.hostname_set ]; then
  echo $HOSTNAME > /etc/hostname
  sed "s/^127\.0\.1\.1\s.*/127.0.1.1\t$HOSTNAME/" -i /etc/hosts
  hostname $HOSTNAME
  touch ~/.hostname_set
fi
