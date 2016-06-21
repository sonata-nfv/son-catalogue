# Convert BSON ID to String
module BSON
  class ObjectId
    def to_json(*)
      to_s.to_json
    end

    def as_json(*)
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

  # field :nsd, type: Hash
  field :vendor, type: String
  field :name, type: String
  field :version, type: String


  validates :vendor, :name, :version, :presence => true

end

class Vnf
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  # include Mongoid::Versioning
  include Mongoid::Attributes::Dynamic
  store_in session: "vnf_db"

  field :vendor, type: String
  field :name, type: String
  field :version, type: String
  # field :vnf_manager, type: String # <- Not applicable yet
  # field :vnfd, type: Hash

  validates :vendor, :name, :version, :presence => true
end
