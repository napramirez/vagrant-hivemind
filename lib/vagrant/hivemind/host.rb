require_relative "constants"

module Vagrant
  module Hivemind
    class Host
      attr_accessor :hostname, :ip_address, :is_control, :memory_in_mb, :box
      @control = nil

      def initialize(hostname, ip_address, is_control = false, memory_in_mb = :small, box = :server)
        @hostname = hostname
        @ip_address = ip_address
        @is_control = is_control
        @memory_in_mb = memory_in_mb
        @box = box
      end

      def self.control
        unless @control
          @control = self.new Constants::CONTROL, Util::Network.starting_ip_address, true, :extra_small, :server
        end
        @control
      end

    end
  end
end
