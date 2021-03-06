require "optparse"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class Halt < Vagrant.plugin("2", :command)
          include Vagrant::Hivemind::Constants
          include Vagrant::Hivemind::Util

        def self.synopsis
          "Stops a Drone in the Hive"
        end

        def execute
          options = {}

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind halt [options]"
            o.separator ""
            o.separator "Options:"
            o.separator ""

            o.on("-n", "--hostname HOSTNAME", "A comma-separated list of Drone hostnames (REQUIRED)") do |n|
              options[:hostname] = Args.from_csv n
            end

            o.on("-f", "--force", "Force shut down (equivalent of pulling power)") do |f|
              options[:force] = f
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

          Vagrant::Hivemind::Util::Vagrantfile.generate_hivemind_vagrantfile @env, hosts, root_path

          with_target_vms(hostnames) do |vm|
            vm.action(:halt, force_halt: options[:force])
          end

          0
        end

      end
    end
  end
end
