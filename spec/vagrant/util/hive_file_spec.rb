require "spec_helper"
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
