require "nokogiri"

module CC
  module Engine
    class Content
      def self.scrape_content_bodies
        new.scrape_xml_data
      end

      def initialize
        @issue_content = Hash.new({})
      end

      def scrape_xml_data
        xml_data.each do |checks_file|
          section_title = checks_file.css("head title").text.split(" ").join
          sections = checks_file.css("body section")

          if sections.length > 1
            issue_subsections = sections[1..-1]

            issue_subsections.map do |issue|
              tmp_issue = {}
              issue.css("subsection").each do |issue_subsection|

                html = issue_subsection.children.to_html
                if html && !html.empty?
                  subsection_name = issue_subsection["name"]
                  if subsection_name == "Package"
                    tmp_issue[subsection_name] = html.strip.split.sort.last
                  else
                    tmp_issue[subsection_name] = issue_subsection.children.to_html
                  end
                  issue_identifier = "#{tmp_issue["Package"]}.#{issue["name"]}Check"
                  @issue_content[issue_identifier] = tmp_issue
                end
              end
            end
          end
        end
        @issue_content
      end

      private

      def xml_files
        Dir.glob("/usr/src/app/data/config_*")
      end

      def xml_data
        xml_files.map{|f| Nokogiri::XML(File.read(f)) }
      end

    end
  end
end
