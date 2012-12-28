class Chef
  class Knife
    class PushyJobStatus < Chef::Knife
      banner "pushy job status <job id>"

      def run
        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        job_id = name_args[0]
        job = rest.get_rest("pushy/jobs/#{job_id}")
        if job.kind_of?(Array) # list of jobs
          output(as_map(job))
        else
          output(job)
        end
      end

      def as_map(jobs)
        jobs.inject({}) { |map, job| map[job['id']] =job;map}
      end
    end
  end
end

