module Vagrant
  module Hivemind
    module Command
      class List < Vagrant.plugin("2", :command)
        def self.synopsis
          "Lists all the Drones in the Hive"
        end

        def execute
          puts "List!"
          0
        end
      end
    end
  end
end
