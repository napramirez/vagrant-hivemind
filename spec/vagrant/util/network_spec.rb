require "spec_helper"
require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"

describe Vagrant::Hivemind::Util::Network, "#is_valid_hostname?" do

  context "when the hostname is nil" do
    it "should return false" do
      hostname = nil
      result = Vagrant::Hivemind::Util::Network.is_valid_hostname? hostname
      expect(result).to be false
    end
  end

  context "when the hostname is an empty string" do
    it "should return false" do
      hostname = ""
      result = Vagrant::Hivemind::Util::Network.is_valid_hostname? hostname
      expect(result).to be false
    end
  end

  context "when the hostname is beyond the maximum allowable length" do
    it "should return false" do
      hostname = "a" * (Vagrant::Hivemind::Constants::SIMPLE_HOSTNAME_MAX_LENGTH + 1)
      result = Vagrant::Hivemind::Util::Network.is_valid_hostname? hostname
      expect(result).to be false
    end
  end

  context "when the hostname does not match the prescribed regex" do

    context "and starts with a '-'" do
      it "should return false" do
        hostname = "-drone001"
        result = Vagrant::Hivemind::Util::Network.is_valid_hostname? hostname
        expect(result).to be false
      end
    end

    context "and ends with a '-'" do
      it "should return false" do
        hostname = "drone001-"
        result = Vagrant::Hivemind::Util::Network.is_valid_hostname? hostname
        expect(result).to be false
      end
    end

    context "and contains any of the following special characters: `~!@#$%^&*()_=+[]{}|" do
      it "should return false" do
        hostname = "`~!@#$%^&*()_=+[]{}|"
        result = Vagrant::Hivemind::Util::Network.is_valid_hostname? hostname
        expect(result).to be false
      end
    end

    context "and contains any of the following special characters: ,<.>/?" do
      it "should return false" do
        hostname = ",<.>/?"
        result = Vagrant::Hivemind::Util::Network.is_valid_hostname? hostname
        expect(result).to be false
      end
    end

  end

end

describe Vagrant::Hivemind::Util::Network, "#is_valid_ip_address?" do

  context "when the IP address is nil" do
    it "should return false" do
      ip_address = nil
      result = Vagrant::Hivemind::Util::Network.is_valid_ip_address? ip_address
      expect(result).to be false
    end
  end

  context "when the IP address does not have four (4) octets" do

    context "and has no separator" do
      it "should return false" do
        ip_address = "192"
        result = Vagrant::Hivemind::Util::Network.is_valid_ip_address? ip_address
        expect(result).to be false
      end
    end

    context "and has one (1) separator only" do
      it "should return false" do
        ip_address = "192."
        result = Vagrant::Hivemind::Util::Network.is_valid_ip_address? ip_address
        expect(result).to be false
      end
    end

    context "and has four (4) separators" do
      it "should return false" do
        ip_address = "192.168.50.100.1"
        result = Vagrant::Hivemind::Util::Network.is_valid_ip_address? ip_address
        expect(result).to be false
      end
    end

  end

  context "when the IP address does not match the prescribed regex" do

    context "and any octet exceeds the maximum range" do
      it "should return false" do
        ip_address = "192.168.50.256"
        result = Vagrant::Hivemind::Util::Network.is_valid_ip_address? ip_address
        expect(result).to be false
      end
    end

    context "and any octet is malformed" do
      it "should return false" do
        ip_address = "192.168.50.00001"
        result = Vagrant::Hivemind::Util::Network.is_valid_ip_address? ip_address
        expect(result).to be false
      end
    end

    context "and any octet contains non-numeric characters" do
      it "should return false" do
        ip_address = "192.168.50.a"
        result = Vagrant::Hivemind::Util::Network.is_valid_ip_address? ip_address
        expect(result).to be false
      end
    end

  end

end

describe Vagrant::Hivemind::Util::Network, "#is_valid_port_pair?" do

  context "when the port pair is nil" do
    it "should return false" do
      port_pair = nil
      result = Vagrant::Hivemind::Util::Network.is_valid_port_pair? port_pair
      expect(result).to be false
    end
  end

  context "when the port pair does not have two (2) ports" do

    context "and contains only a single port" do
      it "should return false" do
        port_pair = "22"
        result = Vagrant::Hivemind::Util::Network.is_valid_port_pair? port_pair
        expect(result).to be false
      end
    end

    context "and contains only the guest port" do
      it "should return false" do
        port_pair = "22:"
        result = Vagrant::Hivemind::Util::Network.is_valid_port_pair? port_pair
        expect(result).to be false
      end
    end

    context "and contains only the host port" do
      it "should return false" do
        port_pair = ":22"
        result = Vagrant::Hivemind::Util::Network.is_valid_port_pair? port_pair
        expect(result).to be false
      end
    end

  end

  context "when the port pair does not match the prescribed regex" do

    context "and the guest port contains non-numeric characters" do
      it "should return false" do
        port_pair = "-22:22"
        result = Vagrant::Hivemind::Util::Network.is_valid_port_pair? port_pair
        expect(result).to be false
      end
    end

    context "and the guest port exceeds the maximum limit (for now, 99999)" do
      it "should return false" do
        port_pair = "100000:22"
        result = Vagrant::Hivemind::Util::Network.is_valid_port_pair? port_pair
        expect(result).to be false
      end
    end

    context "and the host port contains non-numeric characters" do
      it "should return false" do
        port_pair = "22:-22"
        result = Vagrant::Hivemind::Util::Network.is_valid_port_pair? port_pair
        expect(result).to be false
      end
    end

    context "and the host port exceeds the maximum limit (for now, 99999)" do
      it "should return false" do
        port_pair = "22:100000"
        result = Vagrant::Hivemind::Util::Network.is_valid_port_pair? port_pair
        expect(result).to be false
      end
    end

  end

end

describe Vagrant::Hivemind::Util::Network, "#is_valid_port_value?" do

  context "when the port is less than the minimum value, zero (0)" do
    it "should return false" do
      port = -1
      result = Vagrant::Hivemind::Util::Network.is_valid_port_value? port
      expect(result).to be false
    end
  end

  context "when the port is more than the maximum value, 16-bit unsigned integer (65535)" do
    it "should return false" do
      port = 65536
      result = Vagrant::Hivemind::Util::Network.is_valid_port_value? port
      expect(result).to be false
    end
  end

end

describe Vagrant::Hivemind::Util::Network, "#port_pair_to_i" do

  context "when the format-valid port pair contains a numeric guest port value" do
    it "should return an integer value of the guest port" do
      port_pair = "22:2222"
      result = Vagrant::Hivemind::Util::Network.port_pair_to_i port_pair
      expect(result[0]).to eq 22
    end
  end

  context "when the format-valid port pair contains a numeric host port value" do
    it "should return an integer value of the guest port" do
      port_pair = "22:2222"
      result = Vagrant::Hivemind::Util::Network.port_pair_to_i port_pair
      expect(result[1]).to eq 2222
    end
  end

end

describe Vagrant::Hivemind::Util::Network, "#get_host_port_pair_with_guest_port" do

  let(:forwarded_port) do
    {
      "guest_port" => 22,
      "host_port"  => 2222
    }
  end

  context "when the host does not forward a host port to the target guest port" do
    it "should return nil" do
      guest_port = 80
      host = double("host", :forwarded_ports => [])
      result = Vagrant::Hivemind::Util::Network.get_host_port_pair_with_guest_port guest_port, host
      expect(result).to eq nil
    end
  end

  context "when the host forwards a host port to the target guest port" do
    it "should return the port pair hash" do
      guest_port = 22
      host = double("host", :forwarded_ports => [forwarded_port])
      result = Vagrant::Hivemind::Util::Network.get_host_port_pair_with_guest_port guest_port, host
      expect(result).to eq forwarded_port
    end
  end

end

describe Vagrant::Hivemind::Util::Network, "#get_host_keys_using_host_port" do

  let(:hosts) do
    {
      "drone001" => double("drone001", :forwarded_ports => [{ "guest_port" => 2222, "host_port"  => 2222 }]),
      "drone002" => double("drone002", :forwarded_ports => [{ "guest_port" => 22, "host_port"  => 2222 }]),
      "drone003" => double("drone003", :forwarded_ports => [])
    }
  end

  context "when none of the hosts forward to a guest port using the target host port" do
    it "should return empty" do
      host_port = 8080
      result = Vagrant::Hivemind::Util::Network.get_host_keys_using_host_port host_port, hosts
      expect(result).to eq []
    end
  end

  context "when any of the hosts forward to a guest port using the target host port" do
    it "should return the hostnames of the hosts" do
      host_port = 2222
      result = Vagrant::Hivemind::Util::Network.get_host_keys_using_host_port host_port, hosts
      expect(result).to eq ["drone001", "drone002"]
    end
  end

end

describe Vagrant::Hivemind::Util::Network, "#get_network" do
  context "when the IP address is format-valid" do
    it "should return the network prefix, the first three (3) octets" do
      ip_address = "192.168.50.101"
      result = Vagrant::Hivemind::Util::Network.get_network ip_address
      expect(result).to eq "192.168.50"
    end
  end
end

describe Vagrant::Hivemind::Util::Network, "#starting_ip_address" do
  it "should return the first IP address in the IP address pool " do
    first_ip_address = Vagrant::Hivemind::Constants::PRIVATE_NETWORK.sub('*', "#{Vagrant::Hivemind::Constants::PRIVATE_NETWORK_START}")
    result = Vagrant::Hivemind::Util::Network.starting_ip_address
    expect(result).to eq first_ip_address
  end
end

describe Vagrant::Hivemind::Util::Network, "#highest_ip_address" do

  let(:hosts01) do
    {
      "drone001" => double("drone001", :ip_address => "192.168.50.101"),
      "drone002" => double("drone002", :ip_address => "192.168.50.102"),
      "drone003" => double("drone003", :ip_address => "192.168.50.103")
    }
  end
  let(:hosts02) do
    {
      "drone001" => double("drone001", :ip_address => "192.168.50.124"),
      "drone002" => double("drone002", :ip_address => "192.168.50.180"),
      "drone003" => double("drone003", :ip_address => "192.168.50.103")
    }
  end

  context "when there are no hosts" do
    it "should return nil" do
      result = Vagrant::Hivemind::Util::Network.highest_ip_address {}
      expect(result).to be nil
    end
  end

  context "when there are properly sequenced hosts" do
    it "should return the highest IP address" do
      result = Vagrant::Hivemind::Util::Network.highest_ip_address hosts01
      expect(result).to eq "192.168.50.103"
    end
  end

  context "when there are improperly sequenced hosts" do
    it "should still return the highest IP address" do
      result = Vagrant::Hivemind::Util::Network.highest_ip_address hosts02
      expect(result).to eq "192.168.50.180"
    end
  end

end
