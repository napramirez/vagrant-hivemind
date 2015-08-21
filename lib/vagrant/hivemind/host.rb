require_relative "constants"

module Vagrant
  module Hivemind
    class Host
      attr_accessor :hostname, :ip_address, :is_control, :box_size, :box_type, :forwarded_ports
      @control = nil

      def initialize(hostname, ip_address, options = {})
        @hostname   = hostname
        @ip_address = ip_address
        @is_control = options[:is_control] || false
        @box_size   = options[:box_size]   || :small.to_s
        @box_type   = options[:box_type]   || :server.to_s
        @forwarded_ports = []
      end

      def self.control
        unless @control
          @control = self.new(
            Constants::CONTROL_HOSTNAME,
            Util::Network.starting_ip_address,
            {
              is_control: true,
              box_size:   :small.to_s,
              box_type:   :server.to_s
            })
        end
        @control
      end

    end
  end
end
