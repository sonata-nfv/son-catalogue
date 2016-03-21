/* Simple javascript to create MongoDB databases for son-catalogue
 * This scripts needs to be run with 'installation_mongodb.sh' script
 * for a fresh MongoDB install. However, it can be run as standalone
 * with the next command from prompt:
 * sudo mongo --nodb dbs.js
 *
 * If the MongoDB is not found in localhost or is located on a different
 * port, then change "localhost:27017" accordingly from each 'connect'
 * command to the "ip_address:port" where MongoDB is installed/located.
 * Mongo Shell is required on local machine to apply script on remote a
 * remote database.
 */

db = connect("mongo:27017/ns_catalogue");
db.createCollection("ns");

db = connect("mongo:27017/vnf_catalogue");
db.createCollection("vnfs");

db = connect("mongo:27017/pd_catalogue");
db.createCollection("pd");

