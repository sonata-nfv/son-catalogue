# Convert BSON ID to String
module BSON
	class ObjectId
		def to_json(*args)
			to_s.to_json
		end

		def as_json(*args)
			to_s.as_json
		end
	end
end

class Ns
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Pagination
	include Mongoid::Attributes::Dynamic
	store_in session: "ns_db"

	#field :nsd, type: Hash
	field :ns_group, type: String
	field :ns_name, type: String
	field :ns_version, type: String


	validates :ns_name, :ns_version, :presence => true

end

class Vnf
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Pagination
	#include Mongoid::Versioning
	include Mongoid::Attributes::Dynamic
	store_in session: "vnf_db"

	field :vnf_group, type: String
	field :vnf_name, type: String
	field :vnf_version, type: String
	#field :vnf_manager, type: String # <- Not applicable yet
	#field :vnfd, type: Hash

	validates :vnf_name, :vnf_version, :presence => true
end
