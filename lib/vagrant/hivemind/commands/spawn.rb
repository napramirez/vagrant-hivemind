require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class Spawn < Vagrant.plugin("2", :command)
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

          parser = OptionParser.new do |o|
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

            o.on("-s", "--size SIZE", Vagrant::Hivemind::Constants::BOX_SIZES.keys.map(&:to_s), "The Box Size of the Drone [:extra_small, :small, :medium, :large, :extra_large] (default: :small)") do |s|
              options[:size] = s
            end

            o.on("-t", "--type TYPE", Vagrant::Hivemind::Constants::BOX_TYPES.keys.map(&:to_s), "The Box Type of the Drone [:server, :kde, :unity, :unityi386] (default: :server)") do |t|
              options[:type] = t
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
                @env.ui.info "The specified hostname already exists!"
              else
                if Vagrant::Hivemind::Util::Network.is_valid_hostname? options[:hostname]
                  drone = {
                    options[:hostname] => Vagrant::Hivemind::Host.new(
                      options[:hostname],
                      Vagrant::Hivemind::Util::Network.next_ip_address(hosts),
                      {
                        is_control: options[:control],
                        box_size:   options[:size],
                        box_type:   options[:type]
                      })
                  }
                  Vagrant::Hivemind::Util::HiveFile.write_to hosts.merge(drone), work_dir
                  @env.ui.info "Spawned the Drone with hostname '#{options[:hostname]}'"
                else
                  @env.ui.info "Invalid hostname format!"
                end
              end

            else
              @env.ui.info "There is no Hive file in the working directory."
            end
          else
            parser.parse %w[--help]
          end

          0
        end
      end
    end
  end
end
