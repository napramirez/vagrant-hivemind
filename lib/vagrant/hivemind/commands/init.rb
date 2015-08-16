require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class Init < Vagrant.plugin("2", :command)
        def self.synopsis
          "Initializes a new Hive by creating a '#{Vagrant::Hivemind::Constants::HIVE_FILE}'"
        end

        def execute
          options = {
            :force     => false,
            :directory => []
          }

          OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind init [options]"
            o.separator ""
            o.separator "Options:"
            o.separator ""

            o.on("-f", "--force", "Overwrite an existing '#{Vagrant::Hivemind::Constants::HIVE_FILE}' with a new one") do |f|
              options[:force] = f
            end

            o.on("-d", "--directory DIRECTORY", "Specify the directory where '#{Vagrant::Hivemind::Constants::HIVE_FILE}' will be created (default: current directory)") do |d|
              options[:directory] << d
            end
          end.parse!

          work_dir = options[:directory].empty? ? "." : options[:directory].first

          if Vagrant::Hivemind::Util::HiveFile.exist? work_dir
            if options[:force]
              puts "TODO: Warn that the Hive file has been overwritten"
              write_new_hive_file work_dir
            else
              puts "TODO: Warn that the Hive file already exists!"
            end
          else
            puts "TODO: Inform that the Hive file has been created in the working directory"
            write_new_hive_file work_dir
          end

          0
        end

        def write_new_hive_file(work_dir)
          hosts = {
            "control" => Vagrant::Hivemind::Host.control
          }
          Vagrant::Hivemind::Util::HiveFile.write_to hosts, work_dir
        end
      end
    end
  end
end
