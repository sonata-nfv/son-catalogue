
# @see SonCatalogue
class SonataCatalogue < Sinatra::Application

  require 'json'
  require 'yaml'

	# Read config settings from config file
	#
	# # @return [String, Integer] the address and port of the API
	def read_config()
		begin
			config = YAML.load_file('config/config.yml')
			puts config['address']
			puts config['port']
		rescue YAML::LoadError => e
			# If config file is not found or valid, return with errors
			logger.error "read config error: #{e.to_s}"
		end

		return config['address'], config['port']
	end


	# Checks if a JSON message is valid
	#
	# @param [JSON] message some JSON message
	# @return [Hash, nil] if the parsed message is a valid JSON
	# @return [Hash, String] if the parsed message is an invalid JSON
	def parse_json(message)
		# Check JSON message format
		begin
			parsed_message = JSON.parse(message) # parse json message
		rescue JSON::ParserError => e
			# If JSON not valid, return with errors
			logger.error "JSON parsing: #{e.to_s}"
			return message, e.to_s + "\n"
		end

		return parsed_message, nil
	end

  # Checks if a YAML message is valid
  #
  # @param [YAML] message some YAML message
  # @return [Hash, nil] if the parsed message is a valid YAML
  # @return [Hash, String] if the parsed message is an invalid YAML
  def parse_yaml(message)
    # Check YAML message format
    begin
      parsed_message = YAML.load(message) # parse YAML message
      #puts 'PARSED_MESSAGE: ', parsed_message.to_yaml
    rescue YAML::ParserError => e
      # If YAML not valid, return with errors
      logger.error "YAML parsing: #{e.to_s}"
      return message, e.to_s + "\n"
    end

    return parsed_message, nil
  end

  # Translates a message from YAML to JSON
  #
  # @param [YAML] input_yml some YAML message
  # @return [Hash, nil] if the input message is a valid YAML
  # @return [Hash, String] if the input message is an invalid YAML
	def yaml_to_json(input_yml)
    #puts input_yml.to_s
    puts 'Parsing from YAML to JSON'

		begin
			#output_json = JSON.dump(YAML::load(input_yml))
      #puts 'input: ', input_yml.to_json
      output_json = JSON.dump(input_yml)
      #output_json = JSON.dump(input_yml.to_json)
		rescue
			logger.error "Error parsing from YAML to JSON"
			end

    puts 'Parsing DONE', output_json
		return output_json
	end

  # Translates a message from JSON to YAML
  #
  # @param [JSON] input_json some JSON message
  # @return [Hash, nil] if the input message is a valid JSON
  # @return [Hash, String] if the input message is an invalid JSON
	def json_to_yaml(input_json)
		require 'json'
		require 'yaml'

		begin
			output_yml = YAML.dump(JSON.parse(input_json))
		rescue
			logger.error "Error parsing from JSON to YAML"
			end

		return output_yml
	end

  # Builds an HTTP link for pagination
	#
	# @param [Integer] offset link offset
	# @param [Integer] limit link limit position
	def build_http_link_ns(offset, limit)
		link = ''
		# Next link
		next_offset = offset + 1
		next_nss = Ns.paginate(:page => next_offset, :limit => limit)

		address, port = read_config

		begin
			link << '<' + address.to_s + ':' + port.to_i + '/network-services?offset=' + next_offset.to_s + '&limit=' + limit.to_s + '>; rel="next"' unless next_nss.empty?
		rescue
			logger.error "Error Establishing a Database Connection"
		end

		unless offset == 1
			# Previous link
			previous_offset = offset - 1
			previous_nss = Ns.paginate(:page => previous_offset, :limit => limit)
			unless previous_nss.empty?
				link << ', ' unless next_nss.empty?
				link << '<' + address.to_s + ':' + port.to_i + '/network-services?offset=' + previous_offset.to_s + '&limit=' + limit.to_s + '>; rel="last"'
			end
		end
		link
	end

	# Builds pagination link header
	#
	# @param [Integer] offset the pagination offset requested
	# @param [Integer] limit the pagination limit requested
	# @return [String] the built link to use in header
	def build_http_link_vnf(offset, limit)
		link = ''
		# Next link
		next_offset = offset + 1
		next_vnfs = Vnf.paginate(:page => next_offset, :limit => limit)

		# TODO: link host and port should be configurable (load form config file)
		address, port = read_config
		#puts "configs", address.to_s, port.to_i
		#puts "vars", next_offset.to_s, limit.to_s

		link << '<' + address.to_s + ':' + port.to_s + '/vnfs?offset=' + next_offset.to_s + '&limit=' + limit.to_s + '>; rel="next"' unless next_vnfs.empty?

		unless offset == 1
			# Previous link
			previous_offset = offset - 1
			previous_vnfs = Vnf.paginate(:page => previous_offset, :limit => limit)
			unless previous_vnfs.empty?
				link << ', ' unless next_vnfs.empty?
				# TODO: link host and port should be configurable (load form config file)
				link << '<' + address.to_s + ':' + port.to_s + '/vnfs?offset=' + previous_offset.to_s + '&limit=' + limit.to_s + '>; rel="last"'
			end
		end
		link
	end

	# Extension of build_http_link
	def build_http_link_ns_name(offset, limit, name)
		link = ''
		# Next link
		next_offset = offset + 1
		next_nss = Ns.paginate(:page => next_offset, :limit => limit)
		address, port = read_config

		begin
			link << '<' + address.to_s + ':' + port.to_i + '/network-services/name/' + name.to_s + '?offset=' + next_offset.to_s + '&limit=' + limit.to_s + '>; rel="next"' unless next_nss.empty?
		rescue
			logger.error "Error Establishing a Database Connection"
		end

		unless offset == 1
			# Previous link
			previous_offset = offset - 1
			previous_nss = Ns.paginate(:page => previous_offset, :limit => limit)
			unless previous_nss.empty?
				link << ', ' unless next_nss.empty?
				link << '<' + address.to_s + ':' + port.to_i + '/network-services/name/' + name.to_s + '?offset=' + previous_offset.to_s + '&limit=' + limit.to_s + '>; rel="last"'
			end
		end
		link
	end

	# Method which lists all available interfaces
	#
	# @return [Array] an array of hashes containing all interfaces
	def interfaces_list
		[
				{
						'uri' => '/',
						'method' => 'GET',
						'purpose' => 'REST API Structure and Capability Discovery'
				},
				{
						'uri' => '/network-services',
						'method' => 'GET',
						'purpose' => 'List all NSs'
				},
				{
						'uri' => '/network-services/log',
						'method' => 'GET',
						'purpose' => 'List stored log entries'
				},
				{
						'uri' => '/network-services/id/{sdk_ns_id}',
						'method' => 'GET',
						'purpose' => 'List a specific NS'
				},
				{
						'uri' => '/network-services/name/{external_ns_name}',
						'method' => 'GET',
						'purpose' => 'List a specific NS or specifics NS with common name'
				},
				{
						'uri' => '/network-services/name/{external_ns_name}/version/{external_ns_version}',
						'method' => 'GET',
						'purpose' => 'List a specific NS by name and version'
				},
				{
						'uri' => '/network-services/name/{external_ns_name}/last',
						'method' => 'GET',
						'purpose' => 'List last version of specific NS by name'
				},
				{
						'uri' => '/network-services',
						'method' => 'POST',
						'purpose' => 'Store a new NS'
				},
				{
						'uri' => '/network-services/{sdk_ns_id}',
						'method' => 'PUT',
						'purpose' => 'Update a stored NS'
				},
				{
						'uri' => '/network-services/{sdk_ns_id}',
						'method' => 'DELETE',
						'purpose' => 'Delete a specific NS'
				},
				{
						'uri' => '/vnfs',
						'method' => 'GET',
						'purpose' => 'List all VNFs'
				},
				{
						'uri' => '/vnfs/name/{external_vnf_name}',
						'method' => 'GET',
						'purpose' => 'List a specific VNF or specifics VNF with common name'
				},
				{
						'uri' => '/vnfs/name/{external_vnf_name}/last',
						'method' => 'GET',
						'purpose' => 'List a specific VNF'
				},
				{
						'uri' => '/vnfs/name/{external_vnf_name}/version/{external_vnf_version}',
						'method' => 'GET',
						'purpose' => 'List a specific VNF'
				},
				{
						'uri' => '/vnfs/id/{sdk_vnf_id}',
						'method' => 'GET',
						'purpose' => 'List a specific VNF'
				},
				{
						'uri' => '/vnfs',
						'method' => 'POST',
						'purpose' => 'Store a new VNF'
				},
				{
						'uri' => '/vnfs/id/{sdk_vnf_id}',
						'method' => 'PUT',
						'purpose' => 'Update a stored VNF'
				},
				{
						'uri' => '/vnfs/id/{sdk_vnf_id}',
						'method' => 'DELETE',
						'purpose' => 'Delete a specific VNF'
				}
		]
	end

end
