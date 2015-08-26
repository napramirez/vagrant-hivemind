#!/bin/bash
#

CONTROL_PRIVATE_KEY=$1

cp $CONTROL_PRIVATE_KEY /home/vagrant/.ssh/
chown vagrant.vagrant /home/vagrant/.ssh/id_rsa
chmod 600 /home/vagrant/.ssh/id_rsa
