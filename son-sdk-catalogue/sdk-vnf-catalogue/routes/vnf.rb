=begin
APIDOC comment test
=end

# @see SonataVnfCatalogue
class SonataVnfCatalogue < Sinatra::Application

	before do
		# Gatekeepr authn. code will go here for future implementation
		# --> Gatekeeper authn. disabled
    #	if request.path_info == '/gk_credentials'
    #  		return
    #	end

    	if settings.environment == 'development'
      		return
    	end

    	#authorized?
	end

	# SON-CATALOGUE PLANNING
	#
	#localhost/SDK-catalogue/
	#		POST new VNF/package
	#		GET get all the existing vnfs by id, name, version

	#localhost/SDK-catalogue/id/{id}
	#		GET latest version of this vnf id
	#		DELETE all versions of this vnf id

	#localhost/SDK-catalogue/name/{name}
	#		GET latest version of the vnf with this name

	#localhost/SDK-catalogue/name/getbyVersion?version={x.x}
	#		GET specific version

	# @method get_log
	# @overload get '/vnfs/log'
	#	Returns contents of log file
	# Management method to get log file of catalogue remotely
	get '/vnfs/log' do
		filename = 'log/development.log'

		# For testing purposes only
		begin
			txt = open(filename)

		rescue => err
			logger.error "Error reading log file: #{err}"
			return 500, "Error reading log file: #{err}"
		end

		#return 200, nss.to_json
		return 200, txt.read.to_s
	end

	# @method get_root
	# @overload get '/'
	#       Get all available interfaces
	# Get all interfaces
    get '/' do
    	halt 200, interfaces_list.to_yaml
    end

	# @method get_vnfs
	# @overload get '/vnfs'
	#	Returns a list of VNFs
	# List all VNFs
	get '/vnfs' do
		params[:offset] ||= 1
		params[:limit] ||= 2

		# Only accept positive numbers
		params[:offset] = 1 if params[:offset].to_i < 1
		params[:limit] = 2 if params[:limit].to_i < 1

		# Get paginated list
		vnfs = Vnf.paginate(:page => params[:offset], :limit => params[:limit])

		# Build HTTP Link Header
		headers['Link'] = build_http_link(params[:offset].to_i, params[:limit])

		begin
			vnfs_json = vnfs.to_json
			#puts 'VNFS: ', vnfs_json
			vnfs_yml = json_to_yaml(vnfs_json)
				#puts 'VNFS: ', vnfs_yml
		rescue
			logger.error "Error Establishing a Database Connection"
			return 500, "Error Establishing a Database Connection"
		end

		#halt 200, vnfs.to_json
		return 200, vnfs_yml

	end

	# @method get_vnfs_id
	# @overload get '/vnfs/id/:id'
	#	Show a VNF
	#	@param [String] id VNF ID
	# Show a VNF
	get '/vnfs/id/:id' do
		begin
			vnf = Vnf.find(params[:id])
		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			halt 404
		end

		vnf_json = vnf.to_json
		#puts 'VNFS: ', vnf_json
		vnf_yml = json_to_yaml(vnf_json)
		return 200, vnf_yml

		#halt 200, vnf.to_json
	end

	# @method get_vnfd_external_vnf_version
	# @overload get '/vnfs/:external_vnf_name/version/:version'
	#	Show a VNF
	#	@param [String] external_vnf_name VNF external Name
	# Show a VNF name
	#	@param [Integer] external_vnf_version VNF version
	# Show a VNF version
	get '/vnfs/name/:external_vnf_name/version/:version' do
		begin
#			ns = Ns.find( params[:external_ns_id] )
			vnf = Vnf.find_by( { "vnf_name" =>  params[:external_vnf_name], "vnf_version" => params[:version]})
		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end

		vnf_json = vnf.to_json
		vnf_yml = json_to_yaml(vnf_json)
		return 200, vnf_yml
		#return 200, ns.nsd.to_json
	end

	# @method get_vnfd_external_vnf_last_version
	# @overload get '/vnfs/:external_vnf_name/last'
	#	Show a VNF last version
	#	@param [String] external_ns_name NS external Name
	# Show a VNF name
	get '/vnfs/name/:external_vnf_name/last' do

		# Search and get all items of NS by name
		begin
			puts 'params', params
			vnf = Vnf.where({"vnf_name" => params[:external_vnf_name]}).sort({"vnf_version" => -1}).limit(1).first()
			puts 'VNF: ', vnf

			if vnf == nil
				logger.error "ERROR: VNFD not found"
				return 404
			end

		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end

		vnf_json = vnf.to_json
		puts 'VNF: ', vnf_json

		vnf_yml = json_to_yaml(vnf_json)
		return 200, vnf_yml
	end

	# @method post_vnfs
	# @overload post '/vnfs'
	# 	Post a VNF in YAML format
	# 	@param [JSON] VNF in YAML format
	# Post a VNFD
	post '/vnfs' do
		# Return if content-type is invalid
		return 415 unless request.content_type == 'application/x-yaml'

		# Support compatibility for JSON content-type??
		#halt 415 unless request.content_type == 'application/json'

		# Validate YAML format
		vnf, errors = parse_yaml(request.body.read)
		#ns, errors = parse_yaml(request.body)
		#puts 'NS :', ns.to_yaml
		#puts 'errors :', errors.to_s
		#vnf = parse_json(request.body.read)
		return 400, errors.to_json if errors

		# Translate from YAML format to JSON format
		vnf_json = yaml_to_json(vnf)

		# Validate JSON format
		vnf, errors = parse_json(vnf_json)
		puts 'vnf: ', vnf.to_json
		return 400, errors.to_json if errors

		# Validate VNF
		#halt 400, 'ERROR: VNFD not found' unless vnf.has_key?('vnfd')
		return 400, 'ERROR: VNF Group not found' unless vnf.has_key?('vnf_group')
		return 400, 'ERROR: VNF Name not found' unless vnf.has_key?('vnf_name')
		return 400, 'ERROR: VNF Version not found' unless vnf.has_key?('vnf_version')


		# --> Validation disabled
		# Validate VNFD
		#begin
		#	RestClient.post settings.vnfd_validator + '/vnfds', vnf['vnfd'].to_json, 'X-Auth-Token' => @client_token, :content_type => :json
		#rescue Errno::ECONNREFUSED
		#	halt 500, 'VNFD Validator unreachable'
		#rescue => e
		#	logger.error e.response
		#	halt e.response.code, e.response.body
		#end

		begin
			vnf = Vnf.find_by( {"vnf_name"=>vnf['vnf_name'], "vnf_version"=>vnf['vnf_version']} )
			return 400, 'ERROR: Duplicated VNF Name and Version'
		rescue Mongoid::Errors::DocumentNotFound => e
		end

		# Save to BD
		begin
			new_vnf = Vnf.create!(vnf)
		rescue Moped::Errors::OperationFailure => e
			halt 400, 'ERROR: Duplicated VNF ID' if e.message.include? 'E11000'
			halt 400, e.message
		end

		puts 'New VNF has been added'
		vnf_json = new_vnf.to_json
		vnf_yml = json_to_yaml(vnf_json)
		return 200, vnf_yml
		#return 200, new_vnf.to_json
	end

	# @method delete_vnfd_external_vnf_id
	# @overload delete '/vnfs/id/:id'
	#	Delete a VNF by its ID
	#	@param [String] id VNF ID
	# Delete a VNF
	delete '/vnfs/id/:id' do
		begin
			vnf = Vnf.find(params[:id])
		rescue Mongoid::Errors::DocumentNotFound => e
			halt 404, e.to_s
		end

		vnf.destroy

		return 200, 'OK: VNFD removed'
	end

end