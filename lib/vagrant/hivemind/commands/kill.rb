require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class Kill < Vagrant.plugin("2", :command)
          include Vagrant::Hivemind::Constants
          include Vagrant::Hivemind::Util

        def self.synopsis
          "Removes a Drone in the Hive"
        end

        def execute
          options = {
            :hostname  => nil,
            :directory => []
          }

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind kill [options]"
            o.separator ""
            o.separator "Options:"
            o.separator ""

            o.on("-n", "--hostname HOSTNAME", "The hostname of the Drone (REQUIRED)") do |n|
              options[:hostname] = n
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

          work_dir = get_work_dir_from_options options

          unless HiveFile.exist? work_dir
            @env.ui.error "There is no Hive file in the working directory."
            return 1
          end

          hosts = HiveFile.read_from work_dir

          unless hosts.values.map(&:hostname).include? options[:hostname]
            @env.ui.error "The specified hostname does not exist!"
            return 1
          end

          hosts.delete options[:hostname]
          HiveFile.write_to hosts, work_dir
          @env.ui.info "Killed the Drone with hostname '#{options[:hostname]}'"

          0
        end

        private
          def get_work_dir_from_options(options)
            options[:directory].empty? ? "." : options[:directory].first
          end

      end
    end
  end
end
