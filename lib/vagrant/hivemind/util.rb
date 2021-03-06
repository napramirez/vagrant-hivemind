require "yaml"
require "erb"

require_relative "constants"

module Vagrant
  module Hivemind
    module Util

      class HiveFile
        def self.exist?(path = Pathname.new(Dir.pwd))
          File.exist? get_hive_file_from_path path
        end

        def self.read_from(path = Pathname.new(Dir.pwd))
          hive_file = get_hive_file_from_path path
          hosts_from_hive_file = {}
          hosts_from_hive_file = YAML.load_file(hive_file) if File.exist? hive_file
          hosts_from_hive_file
        end

        def self.write_to(hosts = {}, path = Pathname.new(Dir.pwd))
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

      class Args
        def self.from_csv(csv)
          return nil unless csv
          tokens = csv.delete(" ").split(",").select do |token| !token.empty? end
          tokens.empty? ? nil : tokens
        end
      end

      class Network
        def self.is_valid_hostname?(hostname)
          return false unless hostname and hostname.size > 0 and hostname.size <= Vagrant::Hivemind::Constants::SIMPLE_HOSTNAME_MAX_LENGTH
          return (Vagrant::Hivemind::Constants::SIMPLE_HOSTNAME_REGEX =~ hostname) != nil
        end

        def self.is_valid_ip_address?(ip_address)
          return false unless ip_address and ip_address.split(".").size == 4
          return (Vagrant::Hivemind::Constants::IP_ADDRESS_REGEX =~ ip_address) != nil
        end

        def self.is_valid_port_pair?(port_pair)
          return false unless port_pair and port_pair.split(":").size == 2
          return (Vagrant::Hivemind::Constants::PORT_PAIR_REGEX =~ port_pair) != nil
        end

        def self.is_valid_port_value?(port)
          port >= 0 and port <= 65535
        end

        def self.port_pair_to_i(port_pair)
          port_pair.split(":").map.each { |n| n.to_i }
        end

        def self.get_host_port_pair_with_guest_port(guest_port, host)
          (host.forwarded_ports.select do |forwarded_port| forwarded_port["guest_port"] == guest_port end).first
        end

        def self.get_host_keys_using_host_port(host_port, hosts)
          hosts.keys.select do |key|
            host = hosts[key]
            host.forwarded_ports and (
              host.forwarded_ports.select do |forwarded_port|
                forwarded_port["host_port"] == host_port
              end).size > 0
          end
        end

        def self.get_network(ip_address)
          split_ip_address = ip_address.split(".")
          return nil unless split_ip_address.size == 4
          split_ip_address[0,3].join(".")
        end

        def self.starting_ip_address
          Vagrant::Hivemind::Constants::PRIVATE_NETWORK_IP_ADDRESS_POOL[0]
        end

        def self.highest_ip_address(hosts = {})
          hosts.values.map(&:ip_address).sort.last
        end

        def self.next_ip_address(hosts = {})
          highest_ip_address_index = Vagrant::Hivemind::Constants::PRIVATE_NETWORK_IP_ADDRESS_POOL.find_index highest_ip_address(hosts)

          next_ip_address_index = highest_ip_address_index
          loop do
            next_ip_address_index = ((next_ip_address_index + 1) % Vagrant::Hivemind::Constants::PRIVATE_NETWORK_IP_ADDRESS_POOL.size)
            next_ip_address_candidate = Vagrant::Hivemind::Constants::PRIVATE_NETWORK_IP_ADDRESS_POOL[next_ip_address_index]

            return next_ip_address_candidate unless hosts.values.map(&:ip_address).include? next_ip_address_candidate

            if next_ip_address_index == highest_ip_address_index
              raise StandardError, "There are no more available ip addresses for the private network!"
            end
          end
        end
      end

      class Path
        def self.get_root_path_from_options(options = {})
          path = options[:directory] ||= [Dir.pwd]
          root_path path.first
        end

        def self.cache_path
          cache_path = Pathname.new(Dir.tmpdir).join "hivemind"
          Dir.mkdir cache_path unless cache_path.directory?
          cache_path
        end

        def self.hivemind_home_path
          Pathname.new File.expand_path("../../../../", __FILE__)
        end

        def self.root_path(path = Pathname.new(Dir.pwd))
          Pathname.new File.expand_path path, Pathname.new(Dir.pwd)
        end

        def self.local_data_path(path = Pathname.new(Dir.pwd))
          local_data_path = root_path(path).join ".vagrant"
          Dir.mkdir local_data_path unless local_data_path.directory?
          local_data_path
        end
      end

      class Vagrantfile
        def self.generate_hivemind_vagrantfile(env, hosts, path = Pathname.new(Dir.pwd), generate = false)
          box_types = Vagrant::Hivemind::Constants::BOX_TYPES
          box_sizes = Vagrant::Hivemind::Constants::BOX_SIZES
          cache_path = Path.cache_path
          hivemind_home_path = Path.hivemind_home_path
          local_data_path = Path.local_data_path path
          b = binding

          template_string = ""
          File.open(File.expand_path("../../../../templates/Vagrantfile.erb", __FILE__), "r") do |f|
            template_string = f.read
          end

          template = ERB.new template_string
          template_result = template.result(b)

          if generate
            vagrant_file = File.new(Vagrant::Hivemind::Constants::VAGRANT_FILE, "w+")
          else
            vagrant_file = Tempfile.new("Hivemind_Vagrantfile", path)
          end
          vagrant_file.write template_result
          vagrant_file.close

          env.define_singleton_method :vagrantfile_name= do |vfn| @vagrantfile_name = vfn end
          env.define_singleton_method :root_path= do |root_path| @root_path = root_path end
          env.define_singleton_method :local_data_path= do |local_data_path| @local_data_path = local_data_path end
          env.vagrantfile_name = [File.basename(vagrant_file)]
          env.root_path = path
          env.local_data_path = local_data_path

          nil
        end

        def self.exist?(path = Pathname.new(Dir.pwd))
          File.exist? get_vagrant_file_from_path path
        end

        private
          def self.get_vagrant_file_from_path(path)
            if File.directory? path
              File.join(path, Vagrant::Hivemind::Constants::VAGRANT_FILE)
            else
              path
            end
          end
      end

      class Ansible
        def self.generate_hosts_file(hosts = {}, path = Pathname.new(Dir.pwd))
          datetime_now = DateTime.now.strftime "%F %T %p"
          b = binding

          template_string = ""
          File.open(File.expand_path("../../../../templates/ansible.hosts.erb", __FILE__), "r") do |f|
            template_string = f.read
          end

          template = ERB.new template_string
          template_result = template.result(b)

          ansible_hosts_file = get_ansible_hosts_file_from_path path
          File.open(ansible_hosts_file, "w+") do |f|
            f.write(template_result)
          end
        end

        def self.read_from(path = Pathname.new(Dir.pwd))
          ansible_hosts_file = get_ansible_hosts_file_from_path path
          ansible_hosts = ""
          File.open() do |f|
            ansible_hosts = f.read
          end
          ansible_hosts
        end

        private
          def self.get_ansible_hosts_file_from_path(path)
            if File.directory? path
              File.join(path, Vagrant::Hivemind::Constants::ANSIBLE_HOSTS_FILE)
            else
              path
            end
          end
      end

      class HostsFile
        def self.generate_hosts_file(hosts = {}, path = Pathname.new(Dir.pwd))
          datetime_now = DateTime.now.strftime "%F %T %p"
          b = binding

          template_string = ""
          File.open(File.expand_path("../../../../templates/system.hosts.erb", __FILE__), "r") do |f|
            template_string = f.read
          end

          template = ERB.new template_string
          template_result = template.result(b)

          system_hosts_file = get_system_hosts_file_from_path path
          File.open(system_hosts_file, "w+") do |f|
            f.write(template_result)
          end
        end

        private
          def self.get_system_hosts_file_from_path(path)
            if File.directory? path
              File.join(path, Vagrant::Hivemind::Constants::SYSTEM_HOSTS_FILE)
            else
              path
            end
          end
      end

    end
  end
end
