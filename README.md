[![Build Status](http://jenkins.sonata-nfv.eu/buildStatus/icon?job=son-sdk-catalogue)](http://jenkins.sonata-nfv.eu/job/son-sdk-catalogue)

# SDK Catalogues
This repository contains the development for the SDK catalogues. It holds the API implementation of SDK catalogues for services and functions. Moreover, it is closely related to the [son-catalogue-repos](https://github.com/sonata-nfv/son-catalogue-repos) repository that holds the catalogues of the SONATA Service Platform as well at the [son-schema](https://github.com/sonata-nfv/son-schema) repository that holds the schema for the various descriptors, such as the VNFD and the NSD.

The structure of this repository is as follows:

* SON-SDK-CATALOGUE folder contains the SDK-CATALOGUE API to access to the functions (VNF) Catalogue and the services (NS) Catalogue for the SONATA Software Development Kit (SDK).

## Development
To contribute to the development of the SONATA editor, you may use the very same development workflow as for any other SONATA Github project. That is, you have to fork the repository and create pull requests.

### Dependencies
Ruby gems used (for more details see Gemfile in son-sdk-catalogues folder):

* [Sinatra](http://www.sinatrarb.com/) - Ruby framework
* [Thin](https://github.com/macournoyer/thin/) - Web server
* [json](https://github.com/flori/json) - JSON specification
* [sinatra-contrib](https://github.com/sinatra/sinatra-contrib) - Sinatra extensions
* [rake](http://rake.rubyforge.org/) - Ruby build program with capabilities similar to make
* [JSON-schema](https://github.com/ruby-json-schema/json-schema) - JSON schema validator
* [Rest-client](https://github.com/rest-client/rest-client) - HTTP and REST client
* [Yard](https://github.com/lsegal/yard) - Documentation generator tool
* [rerun](https://github.com/alexch/rerun) - Restarts the app when a file changes (used in development environment)

### Contributing
You may contribute to the editor similar to other SONATA (sub-) projects, i.e. by creating pull requests.

## Installation
Before installing the Catalogues API from source code, it is recommended to install a fresh MongoDB database. It can be done with the "installation_mongodb.sh" script provided in the root folder. This script installs MongoDB and uses the "dbs.js" script to build a database structure in the MongoDB for each catalogue. The default IP address for local development environment is 'localhost:27017'. However, if the MongoDB is already installed, "dbs.js" script can be used standalone, just follow the instructions inside the file. If the MongoDB is found remotely, then the "dbs.js" script needs to be changed according to the IP and Port address of the MongoDB.

For the Catalogues, after cloning the source code from the repository, you can run:

```sh
bundle install
```

It will install all the gems needed to run the SON-CATALOGUE API.

### Dependencies
It is recommended to use Ubuntu 14.04.4 LTS (Trusty Tahr).

This code has been run on Ruby 2.1.

MongoDB is required, this code has been run using MongoDB version 3.2.1.

Root folder provides a script "installation_mongodb.sh" to install and set up MongoDB.

## Usage
The following shows how to start the Catalogue API server:

```sh
rake start
```

The Catalogue's API allows the use of CRUD operations to send, retrieve, update and delete descriptors.
The available descriptors include services (NSD) and functions (VNFD).

For testing the Catalogue, you can use 'curl' tool to send a request to the API. It is required to set the HTTP header 'Content-type' field to 'application/json' or 'application/x-yaml' according to your desired format.
Remember to set the IP address and port accordingly.

Method GET:
To receive all descriptors you can use

```sh
curl http://localhost:4011/network-services
```
```sh
curl http://localhost:4011/vnfs
```

To receive a descriptor by its ID:

```sh
curl http://localhost:4011/network-services/id/9f18bc1b-b18d-483b-88da-a600e9255016
```
```sh
curl http://localhost:4011/vnfs/id/9f18bc1b-b18d-483b-88da-a600e9255017
```

Method POST:
To send a descriptor

```sh
curl -X POST --data-binary @nsd_sample.yaml -H "Content-type:application/x-yaml" http://localhost:4011/network-services
```
```sh
curl -X POST --data-binary @vnfd_sample.yaml -H "Content-type:application/x-yaml" http://localhost:4011/vnfs
```

Method PUT:
To update a descriptor is similar to the POST method, but it is required that a older version of the descriptor is stored in the Catalogue

```sh
curl -X POST --data-binary @nsd_sample.yaml -H "Content-type:application/x-yaml" http://localhost:4011/network-services/id/9f18bc1b-b18d-483b-88da-a600e9255016
```
```sh
curl -X POST --data-binary @vnfd_sample.yaml -H "Content-type:application/x-yaml" http://localhost:4011/vnfs/id/9f18bc1b-b18d-483b-88da-a600e9255017
```

Method DELETE:
To remove a descriptor by its ID

```sh
curl -X DELETE http://localhost:4011/network-services/id/9f18bc1b-b18d-483b-88da-a600e9255016
```
```sh
curl -X DELETE http://localhost:4011/vnfs/id/9f18bc1b-b18d-483b-88da-a600e9255017
```

For more information about usage of Catalogue, please visit the wikipage link below which contains some information to interact and test the Catalogues API.

* [Testing the code](http://wiki.sonata-nfv.eu/index.php/SONATA_Catalogues) - Inside SDK Catalogue API Documentation (It currently works for SDK and SP Catalogues)


The API documentation is expected to be generated with Swagger soon. Further information can be found on SONATA's wikipages link for SONATA Catalogues:

* [SONATA Catalogues](http://wiki.sonata-nfv.eu/index.php/SONATA_Catalogues) - SONATA Catalogues on wikipages

Currently, the API is documented with yardoc and can be built with a rake task:

```sh
rake yard
```

From here you can use the yard server to browse the docs from the source root:

```sh
yard server
```

And they can be viewed from http://localhost:8808/

## License

The SONATA SDK Catalogue is published under Apache 2.0 license. Please see the LICENSE file for more details.

#### Useful Links

To support working and testing with the son-catalogue database it is optional to use next tools:

* [Robomongo](https://robomongo.org/download) - Robomongo 0.9.0-RC4

* [POSTMAN](https://www.getpostman.com/) - Chrome Plugin for HTTP communication

---
#### Lead Developers

The following lead developers are responsible for this repository and have admin rights. They can, for example, merge pull requests.

* Shuaib Siddiqui (shuaibsiddiqui)
* Daniel Guija (dang03)

#### Feedback-Channel

Please use the GitHub issues and the SONATA development mailing list sonata-dev@lists.atosresearch.eu for feedback.
