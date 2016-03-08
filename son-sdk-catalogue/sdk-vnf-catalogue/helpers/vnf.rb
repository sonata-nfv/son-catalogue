
# @see SonataVnfCatalogue
class SonataVnfCatalogue < Sinatra::Application

	# Checks if a JSON message is valid
	#
	# @param [JSON] message some JSON message
	# @return [Hash] if the parsed message is a valid JSON
	# @return [Hash, String] if the parsed message is an invalid JSON
	def parse_json(message)
		# Check JSON message format
		begin
			parsed_message = JSON.parse(message) # parse json message
		rescue JSON::ParserError => e
			# If JSON not valid, return with errors
			logger.error "JSON parsing: #{e.to_s}"
			halt 400, e.to_s + "\n"
		end

		parsed_message
	end

	# Checks if a YAML message is valid
	#
	# @param [YAML] message some YAML message
	# @return [Hash] if the parsed message is a valid YAML
	# @return [Hash, String] if the parsed message is an invalid YAML
	def parse_yaml(message)
		# Check YAML message format
		begin
			parsed_message = YAML.load(message) # parse YAML message
				#puts 'PARSED_MESSAGE: ', parsed_message.to_yaml
		rescue YAML::ParserError => e
			# If YAML not valid, return with errors
			logger.error "YAML parsing: #{e.to_s}"
			halt 400, e.to_s + "\n"
		end

		return parsed_message
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
			halt 400
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

	# Builds pagination link header
	#
	# @param [Integer] offset the pagination offset requested
	# @param [Integer] limit the pagination limit requested
	# @return [String] the built link to use in header
	def build_http_link(offset, limit)
		link = ''
		# Next link
		next_offset = offset + 1
		next_vnfs = Vnf.paginate(:page => next_offset, :limit => limit)
		# TODO: link host and port should be configurable (load form config file)
		link << '<localhost:4569/vnfs?offset=' + next_offset.to_s + '&limit=' + limit.to_s + '>; rel="next"' unless next_vnfs.empty?

		unless offset == 1
			# Previous link
			previous_offset = offset - 1
			previous_vnfs = Vnf.paginate(:page => previous_offset, :limit => limit)
			unless previous_vnfs.empty?
				link << ', ' unless next_vnfs.empty?
				# TODO: link host and port should be configurable (load form config file)
				link << '<localhost:4569/vnfs?offset=' + previous_offset.to_s + '&limit=' + limit.to_s + '>; rel="last"'
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
				'uri' => '/vnfs',
				'method' => 'GET',
				'purpose' => 'List all VNFs'
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
				'uri' => '/vnfs/id/{external_vnf_id}',
				'method' => 'GET',
				'purpose' => 'List a specific VNF'
			},
			{
				'uri' => '/vnfs',
				'method' => 'POST',
				'purpose' => 'Store a new VNF'
			},
			{
				'uri' => '/vnfs/id/{external_vnf_id}',
				'method' => 'PUT',
				'purpose' => 'Update a stored VNF'
			},
			{
				'uri' => '/vnfs/id/{external_vnf_id}',
				'method' => 'DELETE',
				'purpose' => 'Delete a specific VNF'
			}
		]
	end
	
end