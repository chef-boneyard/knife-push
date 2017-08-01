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
    class JobStart < Chef::Knife

      include JobHelpers

      deps do
        require "chef/node"
        require "chef/search/query"
      end

      banner "knife job start <command> [<node> <node> ...]"

      option :run_timeout,
        :long => "--timeout TIMEOUT",
        :description => "Maximum time the job will be allowed to run (in seconds)."

      option :quorum,
            :short => "-q QUORUM",
            :long => "--quorum QUORUM",
            :default => "100%",
            :description => "Pushy job quorum. Percentage (-q 50%) or Count (-q 145)."

      option :search,
            :short => "-s QUERY",
            :long => "--search QUERY",
            :required => false,
            :description => "Solr query for list of job candidates."

      option :send_file,
             :long => "--file FILE",
             :default => nil,
             :description => "File to send to job."

      option :capture_output,
             :long => "--capture",
             :boolean => true,
             :default => false,
             :description => "Capture job output."

      option :with_env,
             :long => "--with-env ENV",
             :default => nil,
             :description => "JSON blob of environment variables to set."

      option :as_user,
             :long => "--as-user USER",
             :default => nil,
             :description => "User id to run as."

      option :in_dir,
             :long => "--in-dir DIR",
             :default => nil,
             :description => "Directory to execute the command in."

      option :nowait,
             :long => "--nowait",
             :short => "-b",
             :boolean => true,
             :default => false,
             :description => "Rather than waiting for each job to complete, exit immediately after starting the job."

      option :poll_interval,
             :long => "--poll-interval RATE",
             :default => 1.0,
             :description => "Repeat interval for job status update (in seconds)."

      def run
        job_name = @name_args[0]
        if job_name.nil?
          ui.error "No job specified."
          show_usage
          exit 1
        end

        @node_names = process_search(config[:search], name_args[1, @name_args.length - 1])

        job_json = {
          "command" => job_name,
          "nodes" => @node_names,
        }

        job_json["quorum"] = get_quorum(config[:quorum], @node_names.length)

        v2_json = job_json.dup

        v2_json["file"] = "raw:" + file_helper(config[:send_file]) if config[:send_file]

        v2_json["capture_output"] = config[:capture_output]
        env = get_env(config)
        v2_json["env"] = env if env
        v2_json["dir"] = config[:in_dir] if config[:in_dir]
        v2_json["user"] = config[:as_user] if config[:as_user]

        begin
          job = run_helper(config, v2_json)
        rescue Net::HTTPServerException => e
          raise e if e.response.code != "400"

          ui.warn "Falling back to Push Jobs v1 mode."

          unless env.empty?
            ui.error "Sending Environment attributes isn't possible for Push Jobs 1.0"
            exit 1
          end

          %i{ send_file dir user }.each do |feature|
            if config[feature]
              ui.error "Can't use a 2.0 feature (#{feature}) with a 1.0 server"
              exit 1
            end
          end

          job = run_helper(config, job_json)
        end

        output(job)

        exit(status_code(job))
      end

    end
  end
end
