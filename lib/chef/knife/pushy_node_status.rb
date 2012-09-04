class Chef
  class Knife
    class PushyNodeStatus < Chef::Knife
      banner "pushy node status [<node> <node> ...]"

      def run
        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        nodes = rest.get_rest(get_url_suffix(name_args))

        output(nodes, name_args)
      end

      private

      def get_url_suffix(node_list=[])

        if node_list.length == 1
          "pushy/node_states/#{node_list[0]}"
        else
          "pushy/node_states"
        end

      end

      def output(nodes, arg_list)
        if nodes.class == Array && arg_list.length > 0
          output_list = arg_list.map do |item|

            nodes.select do |node|
              node["node_name"] == item
            end

          end
        end

        super(output_list || nodes)
      end

    end
  end
end


