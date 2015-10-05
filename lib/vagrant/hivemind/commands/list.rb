require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class List < Vagrant.plugin("2", :command)
          include Vagrant::Hivemind::Constants
          include Vagrant::Hivemind::Util

        def self.synopsis
          "Lists all the Drones in the Hive"
        end

        def execute
          options = {}

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind list [options]"
            o.separator ""
            o.separator "Options:"
            o.separator ""

            o.on("-n", "--hostname", "List the Drones ordered by the hostname") do |n|
              options[:hostname] = n
            end

            o.on("-a", "--ip-address", "List the Drones ordered by the IP address") do |a|
              options[:ip_address] = a
            end

            o.on("-c", "--control", "List the Drones, Control Machines first") do |c|
              options[:control] = c
            end

            o.on("-s", "--size", "List the Drones ordered by the Box Size") do |s|
              options[:size] = s
            end

            o.on("-d", "--directory DIRECTORY", "Specify the directory where '#{HIVE_FILE}' is located (default: current directory)") do |d|
              options[:directory] = []
              options[:directory] << d
            end
          end

          argv = parse_options(opts)
          return if !argv

          root_path = Path.get_root_path_from_options options

          unless HiveFile.exist? root_path
            @env.ui.error "There is no Hive file in the working directory."
            return 1
          end

          hosts = HiveFile.read_from root_path

          sorted_hosts = sort_hosts hosts, options

          Vagrant::Hivemind::Util::Vagrantfile.generate_hivemind_vagrantfile @env, sorted_hosts, root_path

          @env.ui.info "Hostname             IP Address     C Size         Box Type   G D Status"
          sorted_hosts.values.each do |host|
            status = ""
            with_target_vms(host.hostname) do |machine|
              status = machine.state.short_description
            end
            hostname       = host.hostname
            ip_address     = host.ip_address
            is_control_y_n = host.is_control ? 'Y' : 'N'
            box_size       = BOX_SIZES[host.box_size.to_sym][:name]
            box_type       = BOX_TYPES[host.box_type.to_sym][:name]
            is_gui_y_n     = BOX_TYPES[host.box_type.to_sym][:is_gui] ? 'Y' : 'N'
            is_data_detached_y_n = host.is_data_detached ? 'Y' : 'N'
            @env.ui.info "#{'%-20.20s' % hostname} #{'%-14.14s' % ip_address} #{is_control_y_n} #{'%-12.12s' % box_size} #{'%-10.10s' % box_type} #{is_gui_y_n} #{is_data_detached_y_n} #{status}"
          end
          @env.ui.info ""

          0
        end

        private
          def sort_hosts(hosts, options = {})
            sorted_hosts = hosts
            options.keys.each do |key|
              sorted_hosts = sort_hosts_by_hostname(hosts)   if key == :hostname
              sorted_hosts = sort_hosts_by_ip_address(hosts) if key == :ip_address
              sorted_hosts = sort_hosts_by_control(hosts)    if key == :control
              sorted_hosts = sort_hosts_by_box_size(hosts)   if key == :size
            end
            sorted_hosts
          end

          def sort_hosts_by_hostname(hosts)
            (hosts.sort_by { |k,v| v.hostname }).to_h
          end

          def sort_hosts_by_ip_address(hosts)
            (hosts.sort_by { |k,v| v.ip_address }).to_h
          end

          def sort_hosts_by_control(hosts)
            (hosts.sort_by { |k,v| v.is_control.to_s }.reverse).to_h
          end

          def sort_hosts_by_box_size(hosts)
            (hosts.sort_by { |k,v| BOX_SIZES[v.box_size.to_sym][:memory_in_mb] }).to_h
          end

      end
    end
  end
end
