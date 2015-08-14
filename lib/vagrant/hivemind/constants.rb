module Vagrant
  module Hivemind
    module Constants
      HIVE_FILE = "hive.yml"

      BOX_TYPES = {
        :server    => "napramirez/ubuntu-14.04.2-LTS-amd64-server",
        :kde       => "napramirez/kubuntu-14.04.2-LTS-amd64-lite",
        :unity     => "napramirez/ubuntu-14.04.2-LTS-amd64-desktoplite",
        :unityi386 => "napramirez/ubuntu-14.04.2-LTS-i386-desktoplite"
      }

      BOX_SIZES = {
        :extra_small => 256,
        :small       => 512,
        :medium      => 1024,
        :large       => 2048,
        :extra_large => 4096
      }
    end
  end
end
