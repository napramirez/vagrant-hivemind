require "yaml"

require_relative "constants"

module Vagrant
  module Hivemind
    module Util

      class HiveFile
        def self.read_from(path = ".")
          hive_file = get_hive_file_from_path path
          hosts_from_hive_file = {}
          hosts_from_hive_file = YAML.load_file(hive_file) if File.exist? hive_file
          hosts_from_hive_file
        end

        def self.write_to(hosts = {}, path = ".")
          hive_file = get_hive_file_from_path path
          File.open(hive_file, "w+") do |f|
            f.write(hosts.to_yaml)
          end
        end

        private
          def self.get_hive_file_from_path(path)
            if File.directory? path
              File.join(path, Vagrant::Hivemind::Constants::HIVE_FILE)
            else
              path
            end
          end
      end

    end
  end
end
