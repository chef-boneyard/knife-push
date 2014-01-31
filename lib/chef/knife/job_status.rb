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
    class JobStatus < Chef::Knife
      banner "knife job status <job id>"

      def run
        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        job_id = name_args[0]
        job = rest.get_rest("pushy/jobs/#{job_id}")
        output(job)
      end
    end
  end
end

