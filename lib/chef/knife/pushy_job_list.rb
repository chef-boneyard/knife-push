class Chef
  class Knife
    class PushyJobList < Chef::Knife
      banner "pushy job list"

      def run
        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        jobs = rest.get_rest("pushy/jobs")
        output(jobs)
      end
    end
  end
end


