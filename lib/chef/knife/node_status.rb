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
    class NodeStatus < Chef::Knife
      banner "knife node status [<node> <node> ...]"

      def run
        get_node_statuses(name_args).each do |node_status|
          puts "#{node_status['node_name']}\t#{node_status['availability']}"
        end
      end

      private

      def get_node_statuses(name_args = [])
        if name_args.length == 0
          rest.get_rest("pushy/node_states")
        else
          results = []
          name_args.each do |arg|
            if arg.index(":")
              search(:node, arg).each do |node|
                results << rest.get_rest("pushy/node_states/#{node.node_name}")
              end
            else
              results << rest.get_rest("pushy/node_states/#{arg}")
            end
          end
          results
        end
      end

    end
  end
end
