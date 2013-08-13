class Chef
  class Knife
    class JobStart < Chef::Knife

      deps do
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
            :short => '-q QUERY',
            :long => '--query QUERY',
            :required => false,
            :description => 'Solr query for list of job candidates.'

      def run
        if config[:query]
          q = Chef::Search::Query.new
          @type, @query = config[:query].split(/:/)
          @escaped_query = URI.escape(@query,
                                     Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          begin
            nodes = q.search(@type, @escaped_query)
          rescue Net::HTTPServerException => e
            msg Chef::JSONCompat.from_json(e.response.body)['error'].first
            ui.error("knife search failed: #{msg}")
            exit 1
          end
          nodes.each do |node|
            unless node.kind_of?(Chef::Node)
              Chef::Log.error('Invalid search query.')
              exit 1
            end
            nodes << node.name
          end
        else
          nodes = name_args[1,name_args.length-1]
        end

        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        job_json = {
          'command' => name_args[0],
          'nodes' => nodes,
          'quorum' => get_quorum(config[:quorum], nodes.length)
        }
        job_json['run_timeout'] = config[:run_timeout].to_i if config[:run_timeout]
        result = rest.post_rest('pushy/jobs', job_json)
        job_uri = result['uri']
        puts "Started.  Job ID: #{job_uri[-32,32]}"
        previous_state = "Initialized."
        begin
          sleep(0.1)
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

