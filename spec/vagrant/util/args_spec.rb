require "spec_helper"
require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"

describe Vagrant::Hivemind::Util::Args, "#from_csv" do

  context "when the csv string is nil" do
    it "should return nil" do
      csv = nil
      result = Vagrant::Hivemind::Util::Args.from_csv csv
      expect(result).to be nil
    end
  end

  context "when the csv string is empty" do
    it "should return nil" do
      csv = ""
      result = Vagrant::Hivemind::Util::Args.from_csv csv
      expect(result).to be nil
    end
  end

  context "when the csv string is whitespace" do
    it "should return nil" do
      csv = " "
      result = Vagrant::Hivemind::Util::Args.from_csv csv
      expect(result).to be nil
    end
  end

  context "when the csv string contains only the delimiter" do
    it "should return nil" do
      csv = ","
      result = Vagrant::Hivemind::Util::Args.from_csv csv
      expect(result).to be nil
    end
  end

  context "when the csv string contains a non-delimiter value" do
    it "should return the non-delimiter value" do
      csv = "value"
      result = Vagrant::Hivemind::Util::Args.from_csv csv
      expect(result).to eq(["value"])
    end
  end

  context "when the csv string contains two non-delimiter values" do
    it "should return the two non-delimiter values" do
      csv = "value1,value2"
      result = Vagrant::Hivemind::Util::Args.from_csv csv
      expect(result).to eq(["value1","value2"])
    end
  end

  context "when the csv string contains two non-delimiter values with whitespaces" do
    it "should return the two non-delimiter values" do
      csv = "value1 , value2"
      result = Vagrant::Hivemind::Util::Args.from_csv csv
      expect(result).to eq(["value1","value2"])
    end
  end

end