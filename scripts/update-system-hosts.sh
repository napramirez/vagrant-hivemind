#!/bin/bash
#

sudo sed '/^# Hivemind/,$d' -i /etc/hosts
cat /tmp/system.hosts | sudo tee -a /etc/hosts
