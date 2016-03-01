/* Simple javascript to create MongoDB databases for son-catalogue
 * This scripts needs to be run with 'installation_mongodb.sh' script
 * for a fresh MongoDB install. However, it can be run as standalone
 * with the next command from prompt:
 * sudo mongo --nodb dbs.js
 *
 * If the MongoDB is not found in localhost, then change "localhost:27017"
 * accordingly from 'connect' instructions to the "IP_address:port"
 * where MongoDB is located.
 */

db = connect("localhost:27017/ns_catalogue");
db.createCollection("ns");

db = connect("localhost:27017/vnf_catalogue");
db.createCollection("vnfs");

db = connect("localhost:27017/pd_catalogue");
db.createCollection("pd");

