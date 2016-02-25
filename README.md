# SONATA WP3/WP4

## SDK/SP NS/VNF Catalogue

The following repository contains the SONATA CATALOGUE distributed in the next order:
SON-SDK-CATALOGUE folder contains the SDK-NS-CATALOGUE and SDK-VNF-CATALOGUE directories for the Software Development Kit
SON-SP-CATALOGUE folder contains the SP-NS-CATALOGUE and SP-VNF-CATALOGUE directories for the Service Platform

### Requirements

This code has been run on Ruby 2.1.

### Gems used

* [Sinatra](http://www.sinatrarb.com/) - Ruby framework
* [Thin](https://github.com/macournoyer/thin/) - Web server
* [json](https://github.com/flori/json) - JSON specification
* [sinatra-contrib](https://github.com/sinatra/sinatra-contrib) - Sinatra extensions
* [Nokogiri](https://github.com/sparklemotion/nokogiri) - XML parser
* [JSON-schema](https://github.com/ruby-json-schema/json-schema) - JSON schema validator
* [Rest-client](https://github.com/rest-client/rest-client) - HTTP and REST client
* [Yard](https://github.com/lsegal/yard) - Documentation generator tool
* [rerun](https://github.com/alexch/rerun) - Restarts the app when a file changes (used in development environment)

### Installation

First, a fresh MongoDB installation is required, working on localhost:27017
After cloning the source code from the repository, then you can run

```sh
bundle install
```

Which will install all the gems needed to run the SON-CATALOGUE API.

### Tests

TODO: Unit-tests, integration-tests

### API Documentation

The API documentation is expected to be generated with APIDOC soon.
Currently, the API is documented with yardoc and can be built with a rake task:

```sh
rake yard
```

from here you can use the yard server to browse the docs from the source root:

```sh
yard server
```

and they can be viewed from http://localhost:8808/

### Run Server

The following shows how to start the API server:

```sh
rake start
```
