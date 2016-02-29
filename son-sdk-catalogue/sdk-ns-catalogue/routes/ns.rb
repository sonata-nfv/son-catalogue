
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
	#		POST new NSD/package -> DONE
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

		rescue
			logger.error "Error reading log file"
			return 500, "Error reading log file"
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
			ns = Ns.find_by( { "nsd.id" =>  ns['nsd']['id'] , "nsd.version" => ns['nsd']['version'], "nsd.vendor" => ns['nsd']['vendor']})
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

end