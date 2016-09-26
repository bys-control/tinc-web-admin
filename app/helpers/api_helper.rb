module ApiHelper

  def tinc_cmd
    Settings.tinc.cmd
  end

  def dump( element=nil )
    case element
      when :nodes
        dump_element element, 12

      when :edges, :subnets, :connections
        dump_element element

      when :graph, :digraph
        graph = %x(#{tinc_cmd} dump #{element})
        {
          data: graph
        }

      when :invitations
        invitations = %x(#{tinc_cmd} dump #{element})
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
    raw_elements = %x(#{tinc_cmd} dump #{element}).split("\n") || []
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
    raw_info = %x(#{tinc_cmd} info #{element}).split("\n") || []
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

  def export(format=:text)
    raw_config = %x(#{tinc_cmd} export)

    case format
    when :json
      export_json( raw_config )
    else
      raw_config
    end
  end

  def export_all(format=:text)
    raw_config = %x(#{tinc_cmd} export-all)

    case format
    when :json
      config = {}
      raw_config.split("#---------------------------------------------------------------#").each do |config_block|
        data = export_json(config_block)
        config[data[:Name]] = data
      end
      config
    else
      raw_config
    end
  end

  def export_json( config )
    raw_config = config.split("\n") || []
    config = {
      RSA_key: []
    }
    rsa_index = 0
    rsa_capturing = false

    # Extracts config sections
    raw_config.each do |line|
      if line.include? "-----END RSA" and rsa_capturing
        config[:RSA_key][rsa_index].push line
        rsa_capturing = false
        rsa_index += 1
      elsif line.include? "-----BEGIN RSA" or rsa_capturing
        rsa_capturing = true
        if config[:RSA_key][rsa_index].blank?
          config[:RSA_key][rsa_index] = Array(line)
        else
          config[:RSA_key][rsa_index].push line
        end
      else
        raw_param = line.split("=").map{|el| el.strip} || []
        next if raw_param.empty?

        key = raw_param.first.to_sym
        value = raw_param.last

        key_value = case key
        when :Address
          { key => value }
        else
          { key => value }
        end

        if config.key? key
          config[key] = Array(config[key])
          config[key].push value
        else
          config = config.merge! key_value
        end
      end
    end
    config
  end

end
