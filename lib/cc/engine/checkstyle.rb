require "digest/md5"
require "json"
require "posix/spawn"
require "nokogiri"
require "yaml"

module CC
  module Engine
    class Checkstyle
      CONFIG_FILE = "./.mdlrc".freeze
      EXTENSIONS = %w[.java].freeze

      def initialize(root, engine_config, io)
        @root = root
        @engine_config = engine_config
        @io = io
        @contents = YAML.load(File.read("/usr/src/app/check_contents.yml"))
      end

      def run
        return if include_paths.length == 0

        pid, _, out, err = POSIX::Spawn.popen4(command_string)

        xml = out.read

        issues = Nokogiri::XML(xml).xpath("//file//error")

        issues.each do |issue|
          print_issue(issue)
        end
      ensure
        if pid
          STDERR.print err.read
          [out, err].each(&:close)
          Process::waitpid(pid)
        end
      end

      private

      attr_reader :root, :engine_config, :io, :contents

      def include_paths
        return [root] unless engine_config.has_key?("include_paths")

        @include_paths ||= engine_config["include_paths"].select do |path|
          EXTENSIONS.include?(File.extname(path)) || path.end_with?("/")
        end.join(" ")
      end

      def config_path
        return "/usr/src/app/config/codeclimate_checkstyle.xml" unless config

        if File.exists?(config_file)
          return "/code/#{config_file}"
        else
          raise "Config file '#{config_file}' not found"
        end
      end

      def config
        @engine_config["config"]
      end

      def config_file
        if config.is_a? Hash
          config["file"]
        else
          config
        end
      end

      def command_string
        "java -jar /usr/src/app/bin/checkstyle.jar -c #{config_path} -f xml #{include_paths}"
      end

      def format_check_name(issue_name)
        issue_name.split(".").last.split(/(?=[A-Z])/).join(" ")
      end

      def format_path(path)
        path.split("/code/")[1]
      end

      def format_severity(severity)
        case severity
        when "info"
          "info"
        when "warning"
          "normal"
        when "error"
          "critical"
        end
      end

      def print_issue(issue)
        content =
          begin
            key = issue.attributes["source"].value
            @contents.fetch(key).fetch("Description")
          rescue KeyError
            "No description available for #{key}"
          end
        issue = {
          categories: ["Style"],
          check_name: issue.attributes["source"].value,
          description: issue.attributes["message"].value,
          location: {
            lines: {
              begin: issue.attributes["line"].value.to_i,
              end: issue.attributes["line"].value.to_i,
            },
            path: format_path(issue.parent.attributes["name"].value),
          },
          content: {
            body: content
          },
          type: "issue",
          remediation_points: 100_000,
          severity: format_severity(issue.attributes["severity"].value),
        }
        io.print "#{issue.to_json}\0"
      end

    end
  end
end
