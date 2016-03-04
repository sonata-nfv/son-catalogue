=begin
APIDOC comment
=end

# @see NsCatalogue
class SonataNsCatalogue < Sinatra::Application

	before do

		# Gatekeepr authn. code will go here for future implementation
		# --> Gatekeeper authn. disabled
		#if request.path_info == '/gk_credentials'
		#	return
		#end

		if settings.environment == 'development'
			return
		end

		#authorized?
	end

	# SON-CATALOGUE PLANNING
	#
	#localhost/SDK-catalogue/
	#		POST new NSD/package
	#		GET get all the existing services by id, name, version

	#localhost/SDK-catalogue/id/{id}
	#		GET latest version of this service id
	#		DELETE all versions of this service id

	#localhost/SDK-catalogue/name/{name}
	#		GET latest version of the service with this name (is name supposed to be unique?)

	#localhost/SDK-catalogue/name/getbyVersion?version={x.x}
	#		GET specific version


	# @method get_log
	# @overload get '/network-services/log'
	#	Returns contents of log file
	# Management method to get log file of catalogue remotely
	get '/network-services/log' do
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

	# @method get_nss
	# @overload get '/network-services'
	#	Returns a list of NSs
	# List all NSs
	get '/network-services' do
		params[:offset] ||= 1
		params[:limit] ||= 10

		# Only accept positive numbers
		params[:offset] = 1 if params[:offset].to_i < 1
		params[:limit] = 2 if params[:limit].to_i < 1

		# Get paginated list
		nss = Ns.paginate(:page => params[:offset], :limit => params[:limit])

		# Build HTTP Link Header
		headers['Link'] = build_http_link(params[:offset].to_i, params[:limit])

		begin
			nss_json = nss.to_json
			#puts 'NSS: ', nss_json
			nss_yml = json_to_yaml(nss_json)
			#puts 'NSS: ', nss_yml
		rescue
			logger.error "Error Establishing a Database Connection"
			return 500, "Error Establishing a Database Connection"
		end

		#return 200, nss.to_json
		return 200, nss_yml
	end

	# @method get_ns_external_ns_id
	# @overload get '/network-services/id/:external_ns_id'
	#	Show a NS
	#	@param [Integer] external_ns_id NS external ID
	# Show a NS
	get '/network-services/id/:external_ns_id' do
		begin
#			ns = Ns.find( params[:external_ns_id] )
			ns = Ns.find_by( { "nsd.id" =>  params[:external_ns_id]})
		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end

		ns_json = ns.nsd.to_json
		#puts 'NSS: ', nss_json
		ns_yml = json_to_yaml(ns_json)
		return 200, ns_yml
		#return 200, ns.nsd.to_json
	end

	# @method get_nsd_external_ns_version
	# @overload get '/network-services/:external_ns_name/version/:version'
	#	Show a NS
	#	@param [String] external_ns_name NS external Name
	# Show a NS name
	#	@param [Integer] external_ns_version NS version
	# Show a NS version
	get '/network-services/name/:external_ns_name/version/:version' do
		begin
#			ns = Ns.find( params[:external_ns_id] )
			ns = Ns.find_by( { "nsd.properties.name" =>  params[:external_ns_name], "nsd.properties.version" => params[:version]})
		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end

		ns_json = ns.nsd.to_json
		ns_yml = json_to_yaml(ns_json)
		return 200, ns_yml
		#return 200, ns.nsd.to_json
	end

	# @method get_nsd_external_ns_last_version
	# @overload get '/network-services/:external_ns_name/last'
	#	Show a NS last version
	#	@param [String] external_ns_name NS external Name
	# Show a NS name
	get '/network-services/name/:external_ns_name/last' do

		# Search and get all items of NS by name
		begin
			puts 'params', params
			# Get paginated list
			#ns = Ns.paginate(:page => params[:offset], :limit => params[:limit])

			# Build HTTP Link Header
			#headers['Link'] = build_http_link_name(params[:offset].to_i, params[:limit], params[:external_ns_name])

			#ns = Ns.distinct( "nsd.version" )#.where({ "nsd.name" =>  params[:external_ns_name]})
			#ns = Ns.where({"nsd.name" => params[:external_ns_name]})
			ns = Ns.where({"nsd.properties.name" => params[:external_ns_name]}).sort({"nsd.properties.version" => -1}).limit(1).first()
			puts 'NS: ', ns

			if ns == nil
				logger.error "ERROR: NSD not found"
				return 404
			end

		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end

		# Got a list, then for each item convert version field to float and get the higher

		#puts 'NS size: ', ns.size.to_s
		#puts 'version example', '4.1'.to_f

		ns_json = ns.to_json
		puts 'NS: ', ns_json

		#if ns_json == 'null'
		#	logger.error "ERROR: NSD not found"
		#	return 404
		#end
		ns_yml = json_to_yaml(ns_json)
		return 200, ns_yml

		#return 200, ns.nsd.to_json
		#return 200, ns.to_json
	end

	# @method post_nss
	# @overload post '/network-services'
	# Post a NS in YAML format
	# @param [YAML] NS in YAML format
	# Post a NSD
	post '/network-services' do
		# Return if content-type is invalid
		return 415 unless request.content_type == 'application/x-yaml'

		# Support compatibility for JSON content-type??
		#return 415 unless request.content_type == 'application/json'

		# Validate YAML format
		ns, errors = parse_yaml(request.body.read)
		#ns, errors = parse_yaml(request.body)
		#puts 'NS :', ns.to_yaml
		#puts 'errors :', errors.to_s

		return 400, errors.to_json if errors

		# Translate from YAML format to JSON format
		#ns_yml = ns.nsd.to_json
		ns_json = yaml_to_json(ns)
		#ns_json = yaml_to_json(request.body.read)

		# Validate JSON format
		#ns, errors = parse_json(request.body.read)
		#ns, errors = parse_json(ns.to_json)
		ns, errors = parse_json(ns_json)
		puts 'ns: ', ns.to_json
		return 400, errors.to_json if errors

		#logger.debug ns
		# Validate NS
		#return 400, 'ERROR: NS Name not found' unless ns.has_key?('name')
		return 400, 'ERROR: NSD not found' unless ns.has_key?('nsd')

		# --> Validation disabled
		# Validate NSD
		#begin
		#	RestClient.post settings.nsd_validator + '/nsds', ns.to_json, :content_type => :json
		#rescue => e
		#	halt 500, {'Content-Type' => 'text/plain'}, "Validator mS unrechable."
		#end
		
		#vnfExists(ns['nsd']['vnfds'])

		begin
			ns = Ns.find_by( { "nsd.id" =>  ns['nsd']['id'] , "nsd.properties.version" => ns['nsd']['properties']['version'],
												 "nsd.properties.vendor" => ns['nsd']['properties']['vendor']})
			return 400, 'ERROR: Duplicated NS ID, Version or Vendor'
		rescue Mongoid::Errors::DocumentNotFound => e
		end

		# Save to DB
		begin
			new_ns = Ns.create!(ns)
		rescue Moped::Errors::OperationFailure => e
			return 400, 'ERROR: Duplicated NS ID' if e.message.include? 'E11000'
		end

		puts 'New NS has been added'
		ns_json = new_ns.to_json
		ns_yml = json_to_yaml(ns_json)
		return 200, ns_yml
		#return 200, new_ns.to_json
	end

	# @method delete_nsd_external_ns_id
	# @overload delete '/network-service/:external_ns_id'
	#	Delete a NS by its ID
	#	@param [Integer] external_ns_id NS external ID
	# Delete a NS
	delete '/network-services/id/:external_ns_id' do
		#logger.error params[:external_ns_id]
		begin
			#ns = Ns.find( params[:external_ns_id] )
			ns = Ns.find_by( { "nsd.id" =>  params[:external_ns_id]})
		rescue Mongoid::Errors::DocumentNotFound => e
			return 404,'ERROR: Operation failed'
		end
		ns.destroy
		return 200, 'OK: NSD removed'
	end


end