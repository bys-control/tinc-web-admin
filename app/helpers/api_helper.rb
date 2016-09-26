module ApiHelper

  def tinc
    Settings.tinc.cmd
  end

  def dump( element=nil )
    case element
      when :nodes
        dump_element element, 12

      when :edges, :subnets, :connections
        dump_element element

      when :graph, :digraph
        graph = %x(#{tinc} dump #{element})
        {
          data: graph
        }

      when :invitations
        invitations = %x(#{tinc} dump #{element})
        {
          data: invitations
        }

      else
        {
          error: "Tinc element '#{element}' not found. Available elements are 'nodes', 'edges', 'subnets', 'connections', 'graph', 'digraph' and 'invitations'"
        }
    end
  end

  #
  # Dump tinc element information into a Hash
  #
  # @param [Sym] element can be :nodes, :edges, :subnets, :connections, :graph, :digraph, :invitations
  # @param [Fixnum] max_keys maximum number of keys to retrieve
  #
  # @return [Hash] element information
  #
  def dump_element( element, max_keys=0 )
    raw_elements = %x(#{tinc} dump #{element}).split("\n") || []
    elements = {}

    raw_elements.each do |raw_element|
      element = raw_element.split(' ', 2)
      element_name = element.first.to_sym
      element_info = element.last.split(' ', max_keys*2)
      elements[element_name] = Hash[*element_info]
    end

    elements
  end

  def info( element=nil )
    raw_info = %x(#{tinc} info #{element}).split("\n") || []
    info = {}

    raw_info.each do |param|
      raw_param = param.split(":", 2).map{|el| el.strip}
      key = raw_param.first.parameterize.underscore.to_sym
      value = raw_param.last

      key_value = case key
        when :address
          ip, port = value.split(' ', 2)
          port = port.split(' ').last
          {
            address: ip,
            port: port
          }
        when :options, :status
          { key => value.split(' ') }
        else
          { key => value }
      end

      # If key already exists, push values into an array.
      if info.key? key
        info[key] = Array(info[key])
        info[key].push value
      else
        info.merge! key_value
      end

    end

    info
  end


end
