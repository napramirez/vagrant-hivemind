require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class Morph < Vagrant.plugin("2", :command)
        def self.synopsis
          "Changes the settings of a Drone in the Hive"
        end

        def execute
          options = {
            :hostname       => nil,
            :ip_address     => nil,
            :control        => nil,
            :size           => nil,
            :forwarded_port => nil,
            :directory      => []
          }

          parser = OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind morph [options]"
            o.separator ""
            o.separator "Options:"
            o.separator ""

            o.on("-n", "--hostname HOSTNAME", "The hostname of the Drone (REQUIRED)") do |n|
              options[:hostname] = n
            end

            o.on("-a", "--ip-address IPADDRESS", "The new IP address of the Drone") do |a|
              options[:ip_address] = a
            end

            o.on("-c", "--control", "Promote the Drone to be a Control Machine") do |c|
              options[:control] = c
            end

            o.on("-s", "--size SIZE", Vagrant::Hivemind::Constants::BOX_SIZES.keys.map(&:to_s), "The new Box Size of the Drone [:extra_small, :small, :medium, :large, :extra_large] (default: :small)") do |s|
              options[:size] = s
            end

            o.on("-p", "--forwarded-port PORTPAIR", "Forward GUESTPORT to HOSTPORT (the format is GUESTPORT:HOSTPORT)") do |p|
              options[:forwarded_port] = p
            end

            o.on("-d", "--directory DIRECTORY", "Specify the directory where '#{Vagrant::Hivemind::Constants::HIVE_FILE}' is located (default: current directory)") do |d|
              options[:directory] << d
            end
          end

          parser.parse!

          work_dir = options[:directory].empty? ? "." : options[:directory].first

          if options[:hostname]
            if Vagrant::Hivemind::Util::HiveFile.exist? work_dir
              hosts = Vagrant::Hivemind::Util::HiveFile.read_from work_dir

              if hosts.values.map(&:hostname).include? options[:hostname]
                # 0. Validate inputs
                if options[:ip_address]
                  validation_error = is_valid_ip_address?(options[:ip_address], hosts)
                  if validation_error
                    @env.ui.info validation_error
                    return 1
                  end
                end

                # TODO: Morph!
                # 1. Get Drone
                # 2. Modify Drone
                # 3. Detach Drone from hosts
                # 4. Re-attach morphed Drone

                # 1.
                drone = hosts[options[:hostname]]

                # 2.
                

                # 3.
                hosts.delete options[:hostname]
                # 4.
                Vagrant::Hivemind::Util::HiveFile.write_to hosts, work_dir
                @env.ui.info "Morphed the Drone with hostname '#{options[:hostname]}'"
              else
                @env.ui.info "The specified hostname does not exist!"
              end

            else
              @env.ui.info "There is no Hive file in the working directory."
            end
          else
            parser.parse %w[--help]
          end

          0
        end

        def is_valid_ip_address?(ip_address, hosts)
          if !Vagrant::Hivemind::Util::Network.is_valid_ip_address? ip_address
            return "Invalid IP address format!"
          end
          if Vagrant::Hivemind::Util::Network.get_network(ip_address) != Vagrant::Hivemind::Util::Network.get_network(Vagrant::Hivemind::Constants::PRIVATE_NETWORK)
            return "The specified IP address does not belong to the same private network!"
          end
          if hosts.values.map(&:ip_address).include? ip_address
            return "The specified IP address is already used!"
          end
          return nil
        end

      end
    end
  end
end
