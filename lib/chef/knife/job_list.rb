class Chef
  class Knife
    class JobList < Chef::Knife
      banner "knife job list"

      def run
        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        jobs = rest.get_rest("pushy/jobs")
        output(jobs)
      end
    end
  end
end


