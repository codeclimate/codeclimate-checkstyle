require "stringio"
require "cc/engine/checkstyle"

module CC
  module Engine
    describe Checkstyle do
      let(:stdout) { StringIO.new }

      it "gracefully exit if no files to analyze" do
        described_class.new("./fixtures", {}, stdout).run
        expect(stdout.string).to be_empty
      end

      it "aborts on invalid config" do
        expect {
          described_class.new("./fixtures", { "config" => "invalid" }, stdout).run
        }.to raise_error("Config file 'invalid' not found")
      end

      describe "config variations" do
        only_paths = {
          "include_paths" => ["fixtures/Main.java"]
        }
        config_file = {
          "config" => "config/codeclimate_checkstyle.xml",
          "include_paths" => ["fixtures/Main.java"],
        }
        config_hash = {
          "config" => "config/codeclimate_checkstyle.xml",
          "include_paths" => ["fixtures/Main.java"],
        }

        [only_paths, config_file, config_hash].each do |config|
          it "finds issues" do
            described_class.new("./fixtures", config, stdout).run
            expect(stdout.string).to be_an_issue
          end
        end
      end
    end
  end
end
