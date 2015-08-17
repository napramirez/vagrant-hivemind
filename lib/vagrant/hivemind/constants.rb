module Vagrant
  module Hivemind
    module Constants
      HIVE_FILE = "hive.yml"

      BOX_TYPES = {
        :server    => { name: "Server",         box_id: "napramirez/ubuntu-14.04.2-LTS-amd64-server",      is_gui: false },
        :kde       => { name: "KDE",            box_id: "napramirez/kubuntu-14.04.2-LTS-amd64-lite",       is_gui: true },
        :unity     => { name: "Unity",          box_id: "napramirez/ubuntu-14.04.2-LTS-amd64-desktoplite", is_gui: true },
        :unityi386 => { name: "Unity (32-bit)", box_id: "napramirez/ubuntu-14.04.2-LTS-i386-desktoplite",  is_gui: true }
      }

      BOX_SIZES = {
        :extra_small => { name: "Extra Small", short_name: "xs", memory_in_mb:  256 },
        :small       => { name: "Small",       short_name: "s",  memory_in_mb:  512 },
        :medium      => { name: "Medium",      short_name: "m",  memory_in_mb: 1024 },
        :large       => { name: "Large",       short_name: "l",  memory_in_mb: 2048 },
        :extra_large => { name: "Extra Large", short_name: "xl", memory_in_mb: 4096 }
      }

      CONTROL_HOSTNAME = "control"

      PRIVATE_NETWORK = "192.168.50.*"
      PRIVATE_NETWORK_START = 100

      SIMPLE_HOSTNAME_REGEX = /^[A-Za-z0-9]+([\-]{0,1}[A-Za-z0-9]+)*$/
      SIMPLE_HOSTNAME_MAX_LENGTH = 20
    end
  end
end
