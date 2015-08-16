require_relative "constants"

module Vagrant
  module Hivemind
    class Host
      attr_accessor :hostname, :ip_address, :is_control, :memory_in_mb, :box, :is_gui
      @control = nil

      def initialize(hostname, ip_address, is_control = false, memory_in_mb = Constants::BOX_SIZES[:small], box = Constants::BOX_TYPES[:server], is_gui = false)
        @hostname = hostname
        @ip_address = ip_address
        @is_control = is_control
        @memory_in_mb = memory_in_mb
        @box = box
        @is_gui = is_gui
      end

      def self.control
        unless @control
          @control = self.new Constants::CONTROL, Util::Network.starting_ip_address, true, Constants::BOX_SIZES[:extra_small], Constants::BOX_TYPES[:server], false
        end
        @control
      end

    end
  end
end
