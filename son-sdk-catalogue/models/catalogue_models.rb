##
## Copyright (c) 2015 SONATA-NFV, i2CAT Foundation
## ALL RIGHTS RESERVED.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
## Neither the name of the SONATA-NFV, i2CAT Foundation
## nor the names of its contributors may be used to endorse or promote
## products derived from this software without specific prior written
## permission.
##
## This work has been performed in the framework of the SONATA project,
## funded by the European Commission under Grant number 671517 through
## the Horizon 2020 and 5G-PPP programmes. The authors would like to
## acknowledge the contributions of their colleagues of the SONATA
## partner consortium (www.sonata-nfv.eu).

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

# Sonata class for Catalogue Services
class Ns
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include Mongoid::Attributes::Dynamic
  store_in session: 'ns_db'

  field :vendor, type: String
  field :name, type: String
  field :version, type: String

  validates :vendor, :name, :version, :presence => true
end

# Sonata class for Catalogue Functions
class Vnf
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  # include Mongoid::Versioning
  include Mongoid::Attributes::Dynamic
  store_in session: 'vnf_db'

  field :vendor, type: String
  field :name, type: String
  field :version, type: String
  # field :vnf_manager, type: String # <- Not applicable yet

  validates :vendor, :name, :version, :presence => true
end

# Sonata class for Catalogue Services
# class Vnf_Ns_map ## Temporary name
#  include Mongoid::Document
#  include Mongoid::Timestamps
#  include Mongoid::Pagination
#  include Mongoid::Attributes::Dynamic
#  store_in session: 'map_db'

#  field :vendor, type: String
#  field :name, type: String
#  field :version, type: String

#  validates :vendor, :name, :version, :presence => true
# end
