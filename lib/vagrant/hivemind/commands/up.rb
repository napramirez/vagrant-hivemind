require "optparse"
require "erb"

require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"
require "vagrant/hivemind/host"

module Vagrant
  module Hivemind
    module Command
      class Up < Vagrant.plugin("2", :command)
          include Vagrant::Hivemind::Constants
          include Vagrant::Hivemind::Util

        def self.synopsis
          "Starts and provisions a Drone in the Hive"
        end

        def execute
          options = {}

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind up [options]"
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

          Vagrant::Hivemind::Util::Vagrantfile.generate_hivemind_vagrantfile @env, hosts, root_path
          Ansible.generate_hosts_file hosts, Path.local_data_path(root_path)
          HostsFile.generate_hosts_file hosts, Path.local_data_path(root_path)

          machines = []
          @env.batch do |batch|
            with_target_vms(hostnames) do |machine|
              @env.ui.info(I18n.t("vagrant.commands.up.upping",
                name: machine.name,
                provider: machine.provider_name))

              machines << machine

              batch.action(machine, :up, options)
            end
          end

          if machines.empty?
            @env.ui.info(I18n.t("vagrant.up_no_machines"))
            return 1
          end

          machines.each do |m|
            next if !m.config.vm.post_up_message
            next if m.config.vm.post_up_message == ""

            @env.ui.info("", prefix: false)

            m.ui.success(I18n.t(
              "vagrant.post_up_message",
              name: m.name.to_s,
              message: m.config.vm.post_up_message))
          end

          0
        end

      end
    end
  end
end
