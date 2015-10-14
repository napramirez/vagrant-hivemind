require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class Desc < Vagrant.plugin("2", :command)
          include Vagrant::Hivemind::Constants
          include Vagrant::Hivemind::Util

        def self.synopsis
          "Displays the settings of a Drone in the Hive"
        end

        def execute
          options = {}

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind desc [options]"
            o.separator ""
            o.separator "Options:"
            o.separator ""

            o.on("-n", "--hostname HOSTNAME", "The hostname of the Drone (REQUIRED)") do |n|
              options[:hostname] = Args.from_csv n
            end

            o.on("-d", "--directory DIRECTORY", "Specify the directory where '#{HIVE_FILE}' is located (default: current directory)") do |d|
              options[:directory] = []
              options[:directory] << d
            end
          end

          argv = parse_options(opts)
          return if !argv

          unless options[:hostname]
            @env.ui.info opts.help
            return 0
          end

          root_path = Path.get_root_path_from_options options

          unless HiveFile.exist? root_path
            @env.ui.error "There is no Hive file in the working directory."
            return 1
          end

          hosts = HiveFile.read_from root_path

          hostnames = []
          options[:hostname].each do |hostname|
            if hosts.values.map(&:hostname).include? hostname
              hostnames << hostname
            else
              @env.ui.warn "The hostname '#{hostname}' does not exist in the Hive!"
            end
          end

          hostnames.each do |hostname|

          host = hosts[hostname]

          @env.ui.info "Hostname        : #{host.hostname}"
          @env.ui.info "IP Address      : #{host.ip_address}"
          @env.ui.info "Control Machine : #{host.is_control ? 'Yes' : 'No'}"
          @env.ui.info "Box Size        : #{BOX_SIZES[host.box_size.to_sym][:name]} (#{BOX_SIZES[host.box_size.to_sym][:memory_in_mb]}MB)"
          @env.ui.info "Box Type        : #{BOX_TYPES[host.box_type.to_sym][:name]} (#{BOX_TYPES[host.box_type.to_sym][:box_id]})"
          @env.ui.info "GUI Machine     : #{BOX_TYPES[host.box_type.to_sym][:is_gui] ? 'Yes' : 'No'}"
          @env.ui.info "Detached Data   : #{host.is_data_detached ? 'Yes' : 'No'}"

          if host.forwarded_ports and !host.forwarded_ports.empty?
            @env.ui.info "Forwarded Ports"
            host.forwarded_ports.each do |forwarded_port|
              @env.ui.info "#{'%15.15s' % forwarded_port["guest_port"]} : #{forwarded_port["host_port"]}"
            end
          end
          @env.ui.info ""

          end

          0
        end

      end
    end
  end
end
