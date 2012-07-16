class Chef
  class Knife
    class PushyStart < Chef::Knife
      banner "pushy start <command> [<node> <node> ...]"

      def run
        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        job_json = {
          'command' => name_args[0],
          'nodes' => name_args[1,name_args.length-1]
        }
        rest.post_rest('pushy/jobs', job_json)
      end
    end
  end
end

