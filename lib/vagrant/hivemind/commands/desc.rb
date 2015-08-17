module Vagrant
  module Hivemind
    module Command
      class Desc < Vagrant.plugin("2", :command)
        def self.synopsis
          "Displays the settings of a Drone in the Hive"
        end

        def execute
          @env.ui.info "Desc!"
          0
        end
      end
    end
  end
end
