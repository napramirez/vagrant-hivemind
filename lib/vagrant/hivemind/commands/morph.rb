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

                if options[:forwarded_port]
                  validation_error = is_valid_forwarded_port?(options[:forwarded_port], hosts)
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
                host = hosts[options[:hostname]]

                # 2.
                if options[:ip_address]
                  host.ip_address = options[:ip_address]
                end

                if options[:control]
                  host.is_control = true
                end

                if options[:size]
                  host.box_size = options[:size]
                end

                if options[:forwarded_port]
                  guest_port, host_port = Vagrant::Hivemind::Util::Network.port_pair_to_i(options[:forwarded_port])
                  host.forwarded_ports ||= []

                  port_pair = Vagrant::Hivemind::Util::Network.get_host_port_pair_with_guest_port(guest_port, host)
                  if port_pair
                    port_pair["host_port"] = host_port
                  else
                    port_pair = {
                      "guest_port" => guest_port,
                      "host_port"  => host_port
                    }
                    host.forwarded_ports << port_pair
                  end
                end

                # 3.
                hosts.delete options[:hostname]

                # 4.
                drone = {
                  options[:hostname] => host
                }
                Vagrant::Hivemind::Util::HiveFile.write_to hosts.merge(drone), work_dir
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

        def is_valid_forwarded_port?(port_pair, hosts)
          if !Vagrant::Hivemind::Util::Network.is_valid_port_pair? port_pair
            return "Invalid port pair format!"
          end

          guest_port, host_port = Vagrant::Hivemind::Util::Network.port_pair_to_i(port_pair)
          if !Vagrant::Hivemind::Util::Network.is_valid_port_value? guest_port
            return "Guest port is out of range!"
          end
          if !Vagrant::Hivemind::Util::Network.is_valid_port_value? host_port
            return "Host port is out of range!"
          end

          if Vagrant::Hivemind::Util::Network.get_host_keys_using_host_port(host_port, hosts).size > 0
            return "Host port is already used!"
          end
        end

      end
    end
  end
end
