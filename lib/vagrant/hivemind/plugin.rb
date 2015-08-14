require "vagrant"

module Vagrant
  module Hivemind
    class Plugin < Vagrant.plugin("2")
      name "Hivemind"
      description "Vagrant extension directives for the Hivemind platform"

      command "hivemind" do
        require_relative "commands/root"
        Command::Root
      end

    end
  end
end
