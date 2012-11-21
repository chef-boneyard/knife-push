class Chef
  class Knife
    class PushyJobStart < Chef::Knife
      banner "pushy job start <command> [<node> <node> ...]"

      option :run_timeout,
        :long => '--timeout TIMEOUT',
        :description => "Maximum time the job will be allowed to run (in seconds)."

      option :quorum,
            :short => '-q QUORUM',
            :long => '--quorum QUORUM',
            :default => '100%',
            :description => 'Pushy job quorum. Percentage (-q 50%) or Count (-q 145).'

      def run
        rest = Chef::REST.new(Chef::Config[:chef_server_url])
        nodes = name_args[1,name_args.length-1]

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
          complete = job['nodes'].keys.inject(0) { |sum,status|
            nodes = job['nodes'][status]
            sum + (%w(new voting running).include?(status) ? 0 : nodes.length)
          }
          if job['status'] == 'running'
            [false, job['status'].capitalize + " (#{complete}/#{total} complete) ..."]
          else
            [true, job['status'].capitalize + " (#{complete}/#{total} complete)."]
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
            key == "succeeded" || key == "nacked"
          end
          0
        else
          1
        end
      end

    end
  end
end

