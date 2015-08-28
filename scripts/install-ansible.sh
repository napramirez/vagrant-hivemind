#!/bin/bash
#

if [ ! -f ~/.ansible_installed ]; then
  apt-add-repository ppa:ansible/ansible
  apt-get update
  apt-get install -y ansible && touch ~/.ansible_installed
fi
