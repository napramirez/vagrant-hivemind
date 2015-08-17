module Vagrant
  module Hivemind
    module Command
      class Morph < Vagrant.plugin("2", :command)
        def self.synopsis
          "Changes the settings of a Drone in the Hive"
        end

        def execute
          @env.ui.info "Morph!"
          0
        end
      end
    end
  end
end
