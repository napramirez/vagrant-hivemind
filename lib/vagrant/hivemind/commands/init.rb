require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class Init < Vagrant.plugin("2", :command)
          include Vagrant::Hivemind::Constants
          include Vagrant::Hivemind::Util

        def self.synopsis
          "Initializes a new Hive by creating a '#{HIVE_FILE}'"
        end

        def execute
          options = {}

          OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind init [options]"
            o.separator ""
            o.separator "Options:"
            o.separator ""

            o.on("-f", "--force", "Overwrite an existing '#{HIVE_FILE}' with a new one") do |f|
              options[:force] = f
            end

            o.on("-d", "--directory DIRECTORY", "Specify the directory where '#{HIVE_FILE}' will be created (default: current directory)") do |d|
              options[:directory] = []
              options[:directory] << d
            end
          end.parse!

          root_path = Path.get_root_path_from_options options

          if HiveFile.exist? root_path
            if options[:force]
              write_new_hive_file root_path
              @env.ui.info "The Hive file has been overwritten."
              return 0
            else
              @env.ui.error "The Hive file already exists!"
              return 1
            end
          end

          write_new_hive_file root_path
          @env.ui.info "The Hive file has been created in the working directory."

          0
        end

        private
          def write_new_hive_file(path)
            hosts = {
              "control" => Vagrant::Hivemind::Host.control
            }
            HiveFile.write_to hosts, path
          end

      end
    end
  end
end
