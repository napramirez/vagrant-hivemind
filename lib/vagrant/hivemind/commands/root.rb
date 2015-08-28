require "optparse"

module Vagrant
  module Hivemind
    module Command
      class Root < Vagrant.plugin("2", :command)
        def self.synopsis
          "Hivemind operations: init list desc spawn kill morph"
        end

        def initialize(argv, env)
          super

          @main_args, @sub_command, @sub_args = split_main_and_subcommand(argv)

          @subcommands = Vagrant::Registry.new

          @subcommands.register(:init) do
            require_relative "init"
            Init
          end

          @subcommands.register(:list) do
            require_relative "list"
            List
          end

          @subcommands.register(:desc) do
            require_relative "desc"
            Desc
          end

          @subcommands.register(:spawn) do
            require_relative "spawn"
            Spawn
          end

          @subcommands.register(:kill) do
            require_relative "kill"
            Kill
          end

          @subcommands.register(:morph) do
            require_relative "morph"
            Morph
          end

          @subcommands.register(:up) do
            require_relative "up"
            Up
          end

          @subcommands.register(:halt) do
            require_relative "halt"
            Halt
          end

        end

        def execute
          if @main_args.include?("-h") || @main_args.include?("--help")
            return help
          end

          command_class = @subcommands.get(@sub_command.to_sym) if @sub_command
          return help if !command_class || !@sub_command

          command_class.new(@sub_args, @env).execute
        end

        def help
          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant hivemind <command> [<args>]"
            o.separator ""
            o.separator "Available commands:"

            @subcommands.each do |key, data|
              o.separator "#{'%8.6s' % key.to_s}  #{'%.60s' % data.synopsis}"
            end

            o.separator ""
            o.separator "For help on any individual command run `vagrant hivemind <command> -h`"
          end

          @env.ui.info(opts.help, prefix: false)
        end
      end
    end
  end
end
