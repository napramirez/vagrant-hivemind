require 'vagrant/hivemind/constants'

module Vagrant
  module Hivemind
    module Command
      class Init < Vagrant.plugin("2", :command)
        def self.synopsis
          "Initializes a new Hive by creating a '#{Vagrant::Hivemind::Constants::HIVE_FILE}'"
        end

        def execute
          puts "Init!"
          0
        end
      end
    end
  end
end
