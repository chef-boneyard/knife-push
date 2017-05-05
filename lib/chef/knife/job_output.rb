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

class Chef
  class Knife
    class JobOutput < Chef::Knife
      banner "knife job output <job id> <node> [<node> ...]"

      option :channel,
             :long => "--channel stdout|stderr",
             :default => "stdout",
             :description => "Which output channel to fetch (default stdout)."

      option :all_nodes,
             :long => "--all-nodes",
             :boolean => true,
             :default => false,
             :description => "Display job output for all nodes."

      def run
        job_id = name_args[0]
        channel = get_channel(config[:channel])
        all_nodes = config[:all_nodes]

        if all_nodes
          job_uri = "pushy/jobs/#{job_id}"

          status_hash = rest.get_rest(job_uri, { "Accept" => "application/json" })

          status_hash['nodes'].each do |status,details|

            status_hash['nodes'][status].each do |fqdn|

              job = get_output(job_id,fqdn,channel)

              output(fqdn)
              output(job)
            end

          end

        else
          node = name_args[1]

          job = get_output(job_id,node,channel)

          output(job)
        end
      end

      def get_output(job_id,node,channel)

        uri = "pushy/jobs/#{job_id}/output/#{node}/#{channel}"

        return rest.get_rest(uri, { "Accept" => "application/octet-stream" })

      end

      def get_channel(channel)
        channel = channel || "stdout"
        case channel
        when "stdout"
          return channel
        when "stderr"
          return channel
        else
          raise "Invalid Format please enter stdout or stderr"
        end
      end

    end
  end
end
