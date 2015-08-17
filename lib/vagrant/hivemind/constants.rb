module Vagrant
  module Hivemind
    module Constants
      HIVE_FILE = "hive.yml"

      BOX_TYPES = {
        :server    => { name: "napramirez/ubuntu-14.04.2-LTS-amd64-server", is_gui: false },
        :kde       => { name: "napramirez/kubuntu-14.04.2-LTS-amd64-lite", is_gui: true },
        :unity     => { name: "napramirez/ubuntu-14.04.2-LTS-amd64-desktoplite", is_gui: true },
        :unityi386 => { name: "napramirez/ubuntu-14.04.2-LTS-i386-desktoplite", is_gui: true }
      }

      BOX_SIZES = {
        :extra_small => 256,
        :small       => 512,
        :medium      => 1024,
        :large       => 2048,
        :extra_large => 4096
      }

      CONTROL = "control"

      PRIVATE_NETWORK = "192.168.50.*"
      PRIVATE_NETWORK_START = 100

      SIMPLE_HOSTNAME_REGEX = /^[A-Za-z0-9]+([\-]{0,1}[A-Za-z0-9]+)*$/
      SIMPLE_HOSTNAME_MAX_LENGTH = 20
    end
  end
end
