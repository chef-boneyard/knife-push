class Chef
  class Knife
    class PushyJobList < Chef::Knife
      banner "pushy job list"

      def run
        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        jobs = rest.get_rest("pushy/jobs")
        output(as_map(jobs))
      end
    end

    def as_map(jobs)
       jobs.inject({}) { |map, job| map[job['id']] =job;map}
    end
  end
end


