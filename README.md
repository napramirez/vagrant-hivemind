# Hivemind Plugin for Vagrant

[![Build Status](https://travis-ci.org/napramirez/vagrant-hivemind.png?branch=master)](https://travis-ci.org/napramirez/vagrant-hivemind)
[![Coverage Status](https://coveralls.io/repos/napramirez/vagrant-hivemind/badge.png?branch=master&service=github)](https://coveralls.io/github/napramirez/vagrant-hivemind?branch=master)

#### Use Vagrant without ever configuring a Vagrantfile!

A Vagrant plugin for users who want to use Vagrant, but don't want to be bothered with Vagrant configuration. This is ideal for developers who just want something up and running in seconds.


## Features
#### Create VM's with the least amount of knowledge

Hivemind provides the simplest of options for defining a VM: hostname, RAM allocation, and VM type.

#### Use the leanest base boxes

Make use of properly crafted base boxes with disk space optimization in mind.  There's a box for your every need: server boxes or desktop boxes.

#### Networking is simple

The VM's are automatically connected in a private network and hostnames are resolvable using a simple mapping.

## Installation

An existing installation of [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) is required.

Run the following command to install the plugin:

    $ vagrant plugin install vagrant-hivemind

## Quickstart

##### Initialize the working directory: *the Hive!*

    $ vagrant hivemind init

##### Create a VM in the working directory: *a Drone in the Hive!*

    $ vagrant hivemind spawn -n drone001

##### Start a VM in the working directory: *get the Drone to work!*

    $ vagrant hivemind up -n drone001

##### For a list of available stuff:

    $ vagrant hivemind --help

## Configuration

Didn't I just say there's nothing to configure? No Vagrantfile, no Ruby config, no properties file!

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/napramirez/vagrant-hivemind](https://github.com/napramirez/vagrant-hivemind). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

