# @copyright Copyright 2014 Chef Software, Inc. All Rights Reserved.
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

require "chef/knife/job_helpers"

class Chef
  class Knife
    class JobOutput < Chef::Knife

      include JobHelpers

      banner "knife job output <job id> <node> [<node> ...]"

      option :channel,
        long: "--channel stdout|stderr",
        default: "stdout",
        description: "Which output channel to fetch (default stdout)."

      option :search,
            :short => "-s QUERY",
            :long => "--search QUERY",
            :required => false,
            :description => "Solr query for list of nodes that can have job output."

      def run
        job_id = name_args[0]
        channel = get_channel(config[:channel])

        node_names = process_search(config[:search], name_args[1, @name_args.length - 1])

        node_names.each do |node|
          uri = "pushy/jobs/#{job_id}/output/#{node}/#{channel}"
          begin
            job = rest.get_rest(uri, { "Accept" => "application/octet-stream" })
            output(node: node, output: job)
          rescue => e
            if e.response.code == "404"
              ui.warn("Could not find output for node #{node}, server returned 404")
            end
          end

        end

      end

      def get_channel(channel)
        channel ||= "stdout"
        return channel if channel == "stdout" || channel == "stderr"

        raise "Invalid Format please enter stdout or stderr"
      end
    end
  end
end
