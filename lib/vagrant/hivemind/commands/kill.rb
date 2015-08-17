module Vagrant
  module Hivemind
    module Command
      class Kill < Vagrant.plugin("2", :command)
        def self.synopsis
          "Removes a Drone in the Hive"
        end

        def execute
          @env.ui.info "Kill!"
          0
        end
      end
    end
  end
end
