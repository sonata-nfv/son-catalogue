#!/bin/bash

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

# +------------------------+
# | Install Ruby libraries |
# +------------------------+

echo "Started installation of dependencies"

# Install Ruby on system
sudo apt-get install -y ruby

# Install RubyGems version 2.6.6
sudo wget http://production.cf.rubygems.org/rubygems/rubygems-2.6.6.tgz
sudo tar xvf rubygems-2.6.6.tgz
sudo ruby rubygems-2.6.6/setup.rb
sudo rm rubygems-2.6.6.tgz

# +--------------------------+
# | Install Gem dependencies |
# +--------------------------+

echo "Installing Bundler"
sudo gem install bundler

echo "Installation completed"
