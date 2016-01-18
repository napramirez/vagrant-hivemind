require "optparse"
require "erb"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class Generate < Vagrant.plugin("2", :command)
          include Vagrant::Hivemind::Constants
          include Vagrant::Hivemind::Util

        def self.synopsis
          "Generates a Vagrantfile of the Hive"
        end

        def execute
          options = {}

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind generate [options]"
            o.separator ""
            o.separator "Options:"
            o.separator ""

            o.on("-f", "--force", "Overwrite an existing '#{VAGRANT_FILE}' with a new one") do |f|
              options[:force] = f
            end

            o.on("-d", "--directory DIRECTORY", "Specify the directory where '#{HIVE_FILE}' is located (default: current directory)") do |d|
              options[:directory] = []
              options[:directory] << d
            end
          end.parse!

          root_path = Path.get_root_path_from_options options

          unless HiveFile.exist? root_path
            @env.ui.error "There is no Hive file in the working directory."
            return 1
          end

          hosts = HiveFile.read_from root_path

          if Vagrant::Hivemind::Util::Vagrantfile.exist? root_path
            if options[:force]
              write_new_vagrant_file hosts, root_path
              @env.ui.info "The Vagrantfile has been overwritten."
              return 0
            else
              @env.ui.error "The Vagrantfile already exists!"
              return 1
            end
          end

          write_new_vagrant_file hosts, root_path

          0
        end

        private
          def write_new_vagrant_file(hosts, path)
            Vagrant::Hivemind::Util::Vagrantfile.generate_hivemind_vagrantfile @env, hosts, path, true
          end

      end
    end
  end
end
