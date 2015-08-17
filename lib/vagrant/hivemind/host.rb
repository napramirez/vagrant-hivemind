require_relative "constants"

module Vagrant
  module Hivemind
    class Host
      attr_accessor :hostname, :ip_address, :is_control, :memory_in_mb, :box
      @control = nil

      def initialize(hostname, ip_address, options = {})
        @hostname     = hostname
        @ip_address   = ip_address
        @is_control   = options[:is_control]   || false
        @memory_in_mb = options[:memory_in_mb] || :small
        @box          = options[:box]          || :server
      end

      def self.control
        unless @control
          @control = self.new Constants::CONTROL, Util::Network.starting_ip_address, { is_control: true, memory_in_mb: :extra_small, box: :server }
        end
        @control
      end

    end
  end
end
