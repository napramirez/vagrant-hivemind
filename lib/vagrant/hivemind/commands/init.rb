require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"

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
              puts "TODO: Overwrite the Hive file with a new one"
            else
              puts "TODO: Warn that the Hive file already exists!"
            end
          else
            puts "TODO: Create new Hive file"
          end

          0
        end
      end
    end
  end
end
