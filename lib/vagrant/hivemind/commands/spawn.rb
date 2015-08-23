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
          options = {
            :hostname  => nil,
            :control   => nil,
            :size      => nil,
            :type      => nil,
            :directory => []
          }

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind spawn [options]"
            o.separator ""
            o.separator "Options:"
            o.separator ""

            o.on("-n", "--hostname HOSTNAME", "The hostname of the Drone (REQUIRED)") do |n|
              options[:hostname] = n
            end

            o.on("-c", "--control", "Assign the Drone to be a Control Machine") do |c|
              options[:control] = c
            end

            o.on("-s", "--size SIZE", BOX_SIZES.keys.map(&:to_s), "The Box Size of the Drone [:extra_small, :small, :medium, :large, :extra_large] (default: :small)") do |s|
              options[:size] = s
            end

            o.on("-t", "--type TYPE", BOX_TYPES.keys.map(&:to_s), "The Box Type of the Drone [:server, :kde, :unity, :unityi386] (default: :server)") do |t|
              options[:type] = t
            end

            o.on("-d", "--directory DIRECTORY", "Specify the directory where '#{HIVE_FILE}' is located (default: current directory)") do |d|
              options[:directory] << d
            end
          end

          argv = parse_options(opts)
          return if !argv

          unless options[:hostname]
            @env.ui.info opts.help
            return 0
          end

          work_dir = options[:directory].empty? ? "." : options[:directory].first

          unless HiveFile.exist? work_dir
            @env.ui.error "There is no Hive file in the working directory."
            return 1
          end

          hosts = HiveFile.read_from work_dir

          if hosts.values.map(&:hostname).include? options[:hostname]
            @env.ui.error "The specified hostname already exists!"
            return 1
          end

          unless Network.is_valid_hostname? options[:hostname]
            @env.ui.error "Invalid hostname format!"
            return 1
          end

          drone = {
            options[:hostname] => Vagrant::Hivemind::Host.new(
              options[:hostname],
              Network.next_ip_address(hosts),
              {
                is_control: options[:control],
                box_size:   options[:size],
                box_type:   options[:type]
              })
          }
          HiveFile.write_to hosts.merge(drone), work_dir
          @env.ui.info "Spawned the Drone with hostname '#{options[:hostname]}'"

          0
        end
      end
    end
  end
end
