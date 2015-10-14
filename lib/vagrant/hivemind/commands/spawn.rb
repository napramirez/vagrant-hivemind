require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class Spawn < Vagrant.plugin("2", :command)
          include Vagrant::Hivemind::Constants
          include Vagrant::Hivemind::Util

        def self.synopsis
          "Creates a new Drone in the Hive"
        end

        def execute
          options = {}

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind spawn [options]"
            o.separator ""
            o.separator "Options:"
            o.separator ""

            o.on("-n", "--hostname HOSTNAME", "A comma-separated list of Drone hostnames (REQUIRED)") do |n|
              options[:hostname] = Args.from_csv n
            end

            o.on("-c", "--control", "Assign the Drone to be a Control Machine") do |c|
              options[:control] = c
            end

            o.on("-s", "--size SIZE", BOX_SIZES.keys.map(&:to_s), "The Box Size of the Drone #{BOX_SIZES.keys.map(&:to_s)} (default: :small)") do |s|
              options[:size] = s
            end

            o.on("-t", "--type TYPE", BOX_TYPES.keys.map(&:to_s), "The Box Type of the Drone #{BOX_TYPES.keys.map(&:to_s)} (default: :server)") do |t|
              options[:type] = t
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

          unless options[:hostname]
            @env.ui.info opts.help
            return 0
          end

          root_path = Path.get_root_path_from_options options

          unless HiveFile.exist? root_path
            @env.ui.error "There is no Hive file in the working directory."
            return 1
          end

          hosts = HiveFile.read_from root_path

          hostnames = []
          options[:hostname].each do |hostname|
            if hosts.values.map(&:hostname).include? hostname
              @env.ui.warn "The hostname '#{hostname}' already exists in the Hive!"
            else
              if Network.is_valid_hostname? hostname
                hostnames << hostname
              else
                @env.ui.warn "Invalid hostname format!"
              end
            end
          end

          if hostnames.empty?
            @env.ui.warn "No Drones to spawn!"
            return 1
          end

          hostnames.each do |hostname|
            drone = {
              hostname => Vagrant::Hivemind::Host.new(
                hostname,
                Network.next_ip_address(hosts),
                {
                  is_control: options[:control],
                  box_size:   options[:size],
                  box_type:   options[:type],
                  is_data_detached: options[:detach]
                })
            }
            hosts = hosts.merge(drone)
            @env.ui.info "Spawned the Drone with hostname '#{hostname}'"
          end
          HiveFile.write_to hosts, root_path

          0
        end

      end
    end
  end
end
