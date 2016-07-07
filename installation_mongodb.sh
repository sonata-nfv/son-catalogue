#!/bin/bash

##
## Copyright (c) 2015 SONATA-NFV , i2CAT Foundation
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
## Neither the name of the SONATA-NFV [, ANY ADDITIONAL AFFILIATION]
## nor the names of its contributors may be used to endorse or promote
## products derived from this software without specific prior written
## permission.
##
## This work has been performed in the framework of the SONATA project,
## funded by the European Commission under Grant number 671517 through
## the Horizon 2020 and 5G-PPP programmes. The authors would like to
## acknowledge the contributions of their colleagues of the SONATA
## partner consortium (www.sonata-nfv.eu).

# +-----------------+
# | Install MongoDB |
# +-----------------+

echo "Started installation of MongoDB"

# Import public key
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

# Create a list file
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# Reload local package database
sudo apt-get update

# Install the latest stable version
sudo apt-get install -y mongodb-org

# Change MongoDB configuration to accept external connections
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

# +--------------------------------------+
# | Disable Transparent Huge Pages (THP) |
# +--------------------------------------+

echo "Disabling Transparent Huge Pages (THP)"
echo 'never' | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
echo 'never' | sudo tee /sys/kernel/mm/transparent_hugepage/defrag

## Create the init script to disable transparent hugepages (THP)
cat > /tmp/disable-transparent-hugepages << EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          disable-transparent-hugepages
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    mongod mongodb-mms-automation-agent
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable Linux transparent huge pages
# Description:       Disable Linux transparent huge pages, to improve
#                    database performance.
### END INIT INFO

case $1 in
  start)
    thp_path=/sys/kernel/mm/transparent_hugepage

    echo 'never' > ${thp_path}/enabled
    echo 'never' > ${thp_path}/defrag

    unset thp_path
    ;;
esac
EOF

# Copy the init script to init.d folder
sudo mv /tmp/disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages

# Make it executable
sudo chmod 755 /etc/init.d/disable-transparent-hugepages

# Configure Ubuntu to run it on boot
sudo update-rc.d disable-transparent-hugepages defaults

echo "Restarting mongod service"
sudo service mongod restart

echo "Creating databases for catalogues"
sudo sudo mongo --nodb dbs.js

echo "Installation completed"
