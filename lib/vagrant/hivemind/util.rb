require "yaml"

require_relative "constants"

module Vagrant
  module Hivemind
    module Util

      class HiveFile
        def self.exist?(path = ".")
          File.exist? get_hive_file_from_path path
        end

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

      class Network
        def self.is_valid_hostname?(hostname)
          return false unless hostname and hostname.size > 0 and hostname.size <= Vagrant::Hivemind::Constants::SIMPLE_HOSTNAME_MAX_LENGTH
          return (Vagrant::Hivemind::Constants::SIMPLE_HOSTNAME_REGEX =~ hostname) != nil
        end

        def self.starting_ip_address
          Vagrant::Hivemind::Constants::PRIVATE_NETWORK.sub('*', (Vagrant::Hivemind::Constants::PRIVATE_NETWORK_START).to_s)
        end

        def self.next_ip_address(hosts = {})
          host_count = hosts.size
          ip_address = Vagrant::Hivemind::Constants::PRIVATE_NETWORK.sub('*', (Vagrant::Hivemind::Constants::PRIVATE_NETWORK_START+host_count).to_s)
          host_count += 1
          ip_address
        end
      end

    end
  end
end
