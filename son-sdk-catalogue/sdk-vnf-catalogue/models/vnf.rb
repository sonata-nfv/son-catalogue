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

class Vnf
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Pagination
	#include Mongoid::Versioning
  include Mongoid::Attributes::Dynamic

  field :vnf_group, type: String
	field :vnf_name, type: String
  field :vnf_version, type: String
	#field :vnf_manager, type: String # <- Not applicable yet
	#field :vnfd, type: Hash

	validates :vnf_name, :vnf_version, :presence => true
end