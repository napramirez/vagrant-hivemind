#!/bin/bash
#

if [ ! -f ~/.drone_ssh_set ]; then
  cat /home/vagrant/.ssh/control_id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
  touch ~/.drone_ssh_set
fi
