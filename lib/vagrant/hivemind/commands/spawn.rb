module Vagrant
  module Hivemind
    module Command
      class Spawn < Vagrant.plugin("2", :command)
        def self.synopsis
          "Creates a new Drone in the Hive"
        end

        def execute
          puts "Spawn!"
          0
        end
      end
    end
  end
end
