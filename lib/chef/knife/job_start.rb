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
        @node_names = []

        job_name = @name_args[0]
        if job_name.nil?
          ui.error "No job specified."
          show_usage
          exit 1
        end

        if config[:search]
          q = Chef::Search::Query.new
          @escaped_query = URI.escape(config[:search],
                                     Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          begin
            nodes = q.search(:node, @escaped_query).first
          rescue Net::HTTPServerException => e
            msg Chef::JSONCompat.from_json(e.response.body)['error'].first
            ui.error("knife search failed: #{msg}")
            exit 1
          end
          nodes.each { |node| @node_names << node.name }
        else
          @node_names = name_args[1,name_args.length-1]
        end

        if @node_names.empty?
          ui.error "No nodes to run job on. Specify nodes as arguments or use -s to specify a search query."
          exit 1
        end

        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        job_json = {
          'command' => job_name,
          'nodes' => @node_names,
          'quorum' => get_quorum(config[:quorum], @node_names.length)
        }
        job_json['run_timeout'] = config[:run_timeout].to_i if config[:run_timeout]
        result = rest.post_rest('pushy/jobs', job_json)
        job_uri = result['uri']
        puts "Started.  Job ID: #{job_uri[-32,32]}"
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

        output(job)

        exit(status_code(job))
      end

      private

      def status_string(job)
        case job['status']
        when 'new'
          [false, 'Initialized.']
        when 'voting'
          [false, job['status'].capitalize + '.']
        else
          total = job['nodes'].values.inject(0) { |sum,nodes| sum+nodes.length }
          in_progress = job['nodes'].keys.inject(0) { |sum,status|
            nodes = job['nodes'][status]
            sum + (%w(new voting running).include?(status) ? 1 : 0)
          }
          if job['status'] == 'running'
            [false, job['status'].capitalize + " (#{in_progress}/#{total} in progress) ..."]
          else
            [true, job['status'].capitalize + '.']
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
            ((num.to_f/100)*total_nodes).ceil
          else
            num.to_i
        end
      end

      def status_code(job)
        if job['status'] == "complete" && job["nodes"].keys.all? do |key|
            key == "succeeded" || key == "nacked" || key == "unavailable"
          end
          0
        else
          1
        end
      end

    end
  end
end
