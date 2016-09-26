class GetTincDataJob < ApplicationJob
  queue_as :default

  def perform
    nodes = get_nodes()
    update_nodes( nodes )
  end

  def get_nodes
    # Get available nodes
    raw_nodes = %x(docker exec tinc tinc dump nodes).split("\n") rescue []
    nodes = {}

    raw_nodes.each do |node|
      raw_node = node.split(' ', 2)
      node_name = raw_node.first.to_sym

      nodes[node_name] = {
        raw_info: raw_node.last
      }

      # Get node info
      raw_node_info = %x(docker exec tinc tinc info #{node_name}).split("\n") rescue []

      raw_node_info.each do |param|
        info = param.split(":", 2).map{|el| el.strip}
        param_name = info.first.parameterize.underscore.to_sym
        param_value = info.last

        case param_name
        when :address
          ip, port = param_value.split(' ', 2)
          port = port.split(' ').last
          nodes[node_name][:address] = ip
          nodes[node_name][:port] = port
        when :options, :status
          nodes[node_name][param_name] = param_value.split(' ').join(', ')
        else
          nodes[node_name][param_name] = param_value
        end
      end
    end

    nodes
  end

  def update_nodes( nodes )
    nodes.each do |node_name, node_info|
      new_node = Node.where(node_id: node_info[:node_id]).first_or_initialize
      new_node.last_seen = nil
      new_node.online_since = nil

      node_info.each do |param, value|
        if new_node.respond_to? param
          new_node[param] = value
        end
      end

      new_node.save
    end
  end
end
