class Chef
  class Knife
    class PushyJobStatus < Chef::Knife
      banner "pushy job status <job id>"

      def run
        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        job_id = name_args[0]
        job = rest.get_rest("pushy/jobs/#{job_id}")
        output(job)

        exit(status_code(job))
      end

      private

      def status_code(job)
        if job['status'] == "complete" && !job["nodes"].keys.include?("failed")
          0
        else
          1
        end
      end

    end
  end
end

