require "stringio"
require "cc/engine/checkstyle"

module CC
  module Engine
    describe Checkstyle do
      let(:stdout) { StringIO.new }

      it "finds basic issues" do
        described_class.new("./fixtures", { "include_paths" => ["fixtures/Main.java"] }, stdout).run
        expect(stdout.string).to_not be_empty
      end

      it "gracefully exit if no files to analyze" do
        described_class.new("./fixtures", {}, stdout).run
        expect(stdout.string).to be_empty
      end

      it "aborts on invalid config" do
        expect {
          described_class.new("./fixtures", { "config" => "invalid" }, stdout).run
        }.to raise_error("Config file 'invalid' not found")
      end
    end
  end
end
