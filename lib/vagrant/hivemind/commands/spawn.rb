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
            :control   => false,
            :size      => :small,
            :type      => :server,
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

            o.on("-s", "--size SIZE", "The Box Size of the Drone [:extra_small, :small, :medium, :large, :extra_large] (default: :small)") do |s|
              options[:size] = s
            end

            o.on("-t", "--type TYPE", "The Box Type of the Drone [:server, :kde, :unity, :unityi386] (default: :server)") do |t|
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
                puts "TODO: Inform that the specified hostname already exists."
              else
                puts "TODO: Validate the format of the hostname"
                puts "TODO: Spawn the Drone and add to the Hive."
              end

            else
              puts "TODO: Inform that there is no Hive file in the working directory."
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
