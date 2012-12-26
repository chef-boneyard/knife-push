class Chef
  class Knife
    class JobStatus < Chef::Knife
      banner "job status <job id>"

      def run
        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        job_id = name_args[0]
        job = rest.get_rest("pushy/jobs/#{job_id}")
        output(job)
      end
    end
  end
end

