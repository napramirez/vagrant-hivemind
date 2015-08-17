require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class List < Vagrant.plugin("2", :command)
        def self.synopsis
          "Lists all the Drones in the Hive"
        end

        def execute
          options = {
            :directory => []
          }

          OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind list [options]"
            o.separator ""
            o.separator "Options:"
            o.separator ""

            o.on("-d", "--directory DIRECTORY", "Specify the directory where '#{Vagrant::Hivemind::Constants::HIVE_FILE}' is located (default: current directory)") do |d|
              options[:directory] << d
            end
          end.parse!

          work_dir = options[:directory].empty? ? "." : options[:directory].first

          if Vagrant::Hivemind::Util::HiveFile.exist? work_dir
            hosts = Vagrant::Hivemind::Util::HiveFile.read_from work_dir

            @env.ui.info "+----------------------+----------------+---+--------------+------------+---+"
            @env.ui.info "| Hostname             | IP Address     | C | Size         | Box Type   | G |"
            @env.ui.info "+----------------------+----------------+---+--------------+------------+---+"
            hosts.values.each do |host|
              hostname       = host.hostname
              ip_address     = host.ip_address
              is_control_y_n = host.is_control ? 'Y' : 'N'
              box_size       = Vagrant::Hivemind::Constants::BOX_SIZES[host.box_size.to_sym][:name]
              box_type       = Vagrant::Hivemind::Constants::BOX_TYPES[host.box_type.to_sym][:name]
              is_gui_y_n     = Vagrant::Hivemind::Constants::BOX_TYPES[host.box_type.to_sym][:is_gui] ? 'Y' : 'N'
              @env.ui.info "| #{'%-20.20s' % hostname} | #{'%-14.14s' % ip_address} | #{is_control_y_n} | #{'%-12.12s' % box_size} | #{'%-10.10s' % box_type} | #{is_gui_y_n} |"
            end
            @env.ui.info "+----------------------+----------------+---+--------------+------------+---+"

          else
            @env.ui.info "There is no Hive file in the working directory."
          end

          0
        end
      end
    end
  end
end
