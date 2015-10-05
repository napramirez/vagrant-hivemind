require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class Morph < Vagrant.plugin("2", :command)
          include Vagrant::Hivemind::Constants
          include Vagrant::Hivemind::Util

        def self.synopsis
          "Changes the settings of a Drone in the Hive"
        end

        def execute
          options = {}

          opts = OptionParser.new do |o|
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

            o.on("-s", "--size SIZE", BOX_SIZES.keys.map(&:to_s), "The new Box Size of the Drone [:extra_small, :small, :medium, :large, :extra_large] (default: :small)") do |s|
              options[:size] = s
            end

            o.on("-p", "--forwarded-port PORTPAIR", "Forward GUESTPORT to HOSTPORT (the format is GUESTPORT:HOSTPORT)") do |p|
              options[:forwarded_port] = p
            end

            o.on("-D", "--detach-data", "Detach the Drone's data directory as a synced folder to the host") do |d|
              options[:detach] = d
            end

            o.on("-d", "--directory DIRECTORY", "Specify the directory where '#{HIVE_FILE}' is located (default: current directory)") do |d|
              options[:directory] = []
              options[:directory] << d
            end
          end

          argv = parse_options(opts)
          return if !argv

          root_path = Path.get_root_path_from_options options

          unless options[:hostname]
            @env.ui.info opts.help
            return 0
          end

          unless HiveFile.exist? root_path
            @env.ui.error "There is no Hive file in the working directory."
            return 1
          end

          hosts = HiveFile.read_from root_path

          unless hosts.values.map(&:hostname).include? options[:hostname]
            @env.ui.error "The specified hostname does not exist!"
            return 1
          end

          if options[:ip_address]
            validation_error = is_valid_ip_address?(options[:ip_address], hosts)
            if validation_error
              @env.ui.error validation_error
              return 1
            end
          end

          if options[:forwarded_port]
            validation_error = is_valid_forwarded_port?(options[:forwarded_port], hosts)
            if validation_error
              @env.ui.error validation_error
              return 1
            end
          end

          host = hosts[options[:hostname]]

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
            guest_port, host_port = Network.port_pair_to_i(options[:forwarded_port])
            host.forwarded_ports ||= []

            port_pair = Network.get_host_port_pair_with_guest_port(guest_port, host)
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

          if options[:detach]
            host.is_data_detached = true
          end

          hosts.delete options[:hostname]
          drone = {
            options[:hostname] => host
          }
          HiveFile.write_to hosts.merge(drone), root_path
          @env.ui.info "Morphed the Drone with hostname '#{options[:hostname]}'"

          0
        end

        private
          def is_valid_ip_address?(ip_address, hosts)
            if !Network.is_valid_ip_address? ip_address
              return "Invalid IP address format!"
            end
            if Network.get_network(ip_address) != Network.get_network(PRIVATE_NETWORK)
              return "The specified IP address does not belong to the private network of the Hive!"
            end
            if hosts.values.map(&:ip_address).include? ip_address
              return "The specified IP address is already used!"
            end
            return nil
          end

          def is_valid_forwarded_port?(port_pair, hosts)
            if !Network.is_valid_port_pair? port_pair
              return "Invalid port pair format!"
            end

            guest_port, host_port = Network.port_pair_to_i(port_pair)
            if !Network.is_valid_port_value? guest_port
              return "Guest port is out of range!"
            end
            if !Network.is_valid_port_value? host_port
              return "Host port is out of range!"
            end

            if Network.get_host_keys_using_host_port(host_port, hosts).size > 0
              return "Host port is already used!"
            end
          end

      end
    end
  end
end
