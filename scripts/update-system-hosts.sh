#!/bin/bash
#

sudo sed '/^# Enter hand-edited entries above this line.$/,$d' -i /etc/hosts
cat /tmp/system.hosts | sudo tee -a /etc/hosts
