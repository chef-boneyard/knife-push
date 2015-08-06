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
    class JobStart < Chef::Knife

      deps do
        require 'chef/rest'
        require 'chef/node'
        require 'chef/search/query'
      end

      banner "knife job start <command> [<node> <node> ...]"

      option :run_timeout,
        :long => '--timeout TIMEOUT',
        :description => "Maximum time the job will be allowed to run (in seconds)."

      option :quorum,
            :short => '-q QUORUM',
            :long => '--quorum QUORUM',
            :default => '100%',
            :description => 'Pushy job quorum. Percentage (-q 50%) or Count (-q 145).'

      option :search,
            :short => '-s QUERY',
            :long => '--search QUERY',
            :required => false,
            :description => 'Solr query for list of job candidates.'

      option :send_file,
             :long => '--file FILE',
             :default => nil,
             :description => 'File to send to job.'

      option :capture_output,
             :long => '--capture',
             :boolean => true,
             :default => false,
             :description => 'Capture job output.'

      option :nowait,
        :long => '--nowait',
        :short => '-b',
        :boolean => true,
        :default => false,
        :description => "Rather than waiting for each job to complete, exit immediately after starting the job."

      option :poll_interval,
             :long => '--poll-interval RATE',
             :default => 1.0,
             :description => "Repeat interval for job status update (in seconds)."
      
      def run
        job_name = @name_args[0]
        if job_name.nil?
          ui.error "No job specified."
          show_usage
          exit 1
        end

        pp :send_file=>config[:send_file]
        
        @node_names = JobHelpers.process_search(config[:search], name_args[1,@name_args.length-1])

        job_json = {
          'command' => job_name,
          'nodes' => @node_names,
          'capture_output' => config[:capture_output]
        }
        job_json['file'] = "raw:" + JobHelpers.file_helper(config[:send_file]) if config[:send_file]
        job_json['quorum'] = JobHelpers.get_quorum(config[:quorum], @node_names.length)

        
        job = JobHelpers.run_helper(config, job_json)


        output(job)

        exit(JobHelpers.status_code(job))

      end

      private

    end
  end
end
