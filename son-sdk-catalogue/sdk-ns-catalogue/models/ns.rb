class Ns
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Pagination
	include Mongoid::Attributes::Dynamic

	#field :nsd, type: Hash
	field :ns_group, type: String
	field :ns_name, type: String
	field :ns_version, type: String


	validates :ns_name, :ns_version, :presence => true
	
end
