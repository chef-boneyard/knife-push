class Chef
  class Knife
    class PushyNodeStatus < Chef::Knife
      banner "pushy node status [<node> <node> ...]"

      def run
        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        get_node_statuses(name_args).each do |node_status|
          puts "#{node_status['node_name']}\t#{node_status['availability']}"
        end
      end

      private

      def get_node_statuses(name_args=[])
        if name_args.length == 0
          rest.get_rest("pushy/node_states")
        else
          results = []
          name_args.each do |arg|
            if arg.index(':')
              search(:node, arg).each do |node|
                results << rest.get_rest("pushy/node_states/#{node.node_name}")
              end
            else
              results << rest.get_rest("pushy/node_states/#{arg}")
            end
          end
          results
        end
      end

    end
  end
end


