require "spec_helper"
require "vagrant/hivemind/constants"
require "vagrant/hivemind/util"

describe Vagrant::Hivemind::Util::HiveFile, "#exist?" do

  context "when there's no existing hive.yml in the current directory" do
    it "should return false" do
      Dir.mktmpdir "test_dir" do |test_dir|
        result = Vagrant::Hivemind::Util::HiveFile.exist? test_dir
        expect(result).to eq false
      end
    end
  end

  context "when there's an existing hive.yml in the current directory" do
    it "should return true" do
      Dir.mktmpdir "test_dir" do |test_dir|
        File.open(Pathname.new(test_dir).join("hive.yml"), "w") do |hive_file|
          result = Vagrant::Hivemind::Util::HiveFile.exist? hive_file
          expect(result).to eq true
        end
      end
    end
  end

end

describe Vagrant::Hivemind::Util::HiveFile, "#get_hive_file_from_path" do

  before :each do
    Vagrant::Hivemind::Util::HiveFile.send(:public, *Vagrant::Hivemind::Util::HiveFile.private_instance_methods)
  end

  context "when there's a specified directory path" do
    it "should return the current directory's hive.yml" do
      Dir.mktmpdir "test_dir" do |test_dir|
        specified_path = Pathname.new(test_dir)
        expected_path = specified_path.join Vagrant::Hivemind::Constants::HIVE_FILE
        result = Vagrant::Hivemind::Util::HiveFile.get_hive_file_from_path specified_path
        expect(result.to_s).to eq expected_path.to_s
      end
    end
  end

  context "when there's a specified file path" do
    it "should return the specified file path" do
      Dir.mktmpdir "test_dir" do |test_dir|
        specified_path = Pathname.new(test_dir).join "custom.hive.yml"
        result = Vagrant::Hivemind::Util::HiveFile.get_hive_file_from_path specified_path
        expect(result.to_s).to eq specified_path.to_s
      end
    end
  end
end
