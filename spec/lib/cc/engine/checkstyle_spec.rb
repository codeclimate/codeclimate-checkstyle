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

      it "uses default config" do
        run_with("include_paths" => ["fixtures/default/Main.java"])
      end

      it "accepts config path" do
        run_with(
          "config" => "config/codeclimate_checkstyle.xml",
          "include_paths" => ["fixtures/default/Main.java"],
        )
      end

      it "accepts config hash" do
        run_with(
          "config" => { "file" => "config/codeclimate_checkstyle.xml" },
          "include_paths" => ["fixtures/default/Main.java"],
        )
      end

      it "accepts config hash without file" do
        run_with(
          "config" => { "key" => "value" },
          "include_paths" => ["fixtures/default/Main.java"],
        )
      end

      def run_with(config)
        described_class.new("./fixtures", config, stdout).run
        expect(stdout.string).to be_an_issue
      end
    end
  end
end
