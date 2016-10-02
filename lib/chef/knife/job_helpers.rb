# @copyright Copyright 2015 Chef Software, Inc. All Rights Reserved.
#
# This file is provided to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file
# except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#

class Chef
  class Knife
    module JobHelpers
      def process_search(search, nodes)
        node_names = []
        if search
          q = Chef::Search::Query.new
          escaped_query = URI.escape(search,
                                      Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          begin
            nodes = q.search(:node, escaped_query).first
          rescue Net::HTTPServerException => e
            msg Chef::JSONCompat.from_json(e.response.body)["error"].first
            ui.error("knife search failed: #{msg}")
            exit 1
          end
          nodes.each { |node| node_names << node.name }
        else
          node_names = nodes
        end

        if node_names.empty?
          ui.error "No nodes to run job on. Specify nodes as arguments or use -s to specify a search query."
          exit 1
        end

        return node_names
      end

      def status_string(job)
        case job["status"]
        when "new"
          [false, "Initialized."]
        when "voting"
          [false, job["status"].capitalize + "."]
        else
          total = job["nodes"].values.inject(0) { |sum, nodes| sum + nodes.length }
          in_progress = job["nodes"].keys.inject(0) do |sum, status|
            nodes = job["nodes"][status]
            sum + (%w{new voting running}.include?(status) ? 1 : 0)
          end
          if job["status"] == "running"
            [false, job["status"].capitalize + " (#{in_progress}/#{total} in progress) ..."]
          else
            [true, job["status"].capitalize + "."]
          end
        end
      end

      def get_quorum(quorum, total_nodes)
        unless qmatch = /^(\d+)(\%?)$/.match(quorum)
          raise "Invalid Format please enter integer or percent"
        end

        num = qmatch[1]

        case qmatch[2]
          when "%" then
            ((num.to_f / 100) * total_nodes).ceil
          else
            num.to_i
        end
      end

      def status_code(job)
        if job["status"] == "complete" && job["nodes"].keys.all? do |key|
             key == "succeeded" || key == "nacked" || key == "unavailable"
           end
          0
        else
          1
        end
      end

      def run_helper(config, job_json)
        job_json["run_timeout"] ||= config[:run_timeout].to_i if config[:run_timeout]

        result = rest.post_rest("pushy/jobs", job_json)
        job_uri = result["uri"]
        puts "Started.  Job ID: #{job_uri[-32, 32]}"
        exit(0) if config[:nowait]
        previous_state = "Initialized."
        begin
          sleep(config[:poll_interval].to_f)
          putc(".")
          job = rest.get_rest(job_uri)
          finished, state = status_string(job)
          if state != previous_state
            puts state
            previous_state = state
          end
        end until finished
        job
      end

      def file_helper(file_name)
        if file_name.nil?
          ui.error "No file specified."
          show_usage
          exit 1
        end
        contents = ""
        if File.exists?(file_name)
          File.open(file_name, "rb") do |file|
            contents = file.read
          end
        else
          ui.error "#{file_name} not found"
          exit 1
        end
        return contents
      end

      def get_env(config)
        env = {}
        begin
          env = config[:with_env] ? JSON.parse(config[:with_env]) : {}
        rescue Exception => e
          Chef::Log.info("Can't parse environment as JSON")
        end
      end
    end
  end
end
