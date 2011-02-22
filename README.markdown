Httpdoc is a very simple documentation generator for generating public API documentation for an HTTP-based web service, parsed from comments embedded in Ruby source code. It's API philosophy-agnostic and supports REST and such if you like. For example, an HTTP API can be described like so:

    ## List stuff.
    #
    # @return A list of stuff in XML.
    # @status 200
    # @status 403 If you do not have permission to list the stuff.
    # @example
    #   @request
    #   GET #{base_url}/create/31
    #   
    #   @response
    #   HTTP/1.1 200 OK
    #   Content-Type: application/xml; charset=utf-8
    #
    #   <stuff>...</stuff>
    # @end
    #
    def list
      ...
    end

Limitations
-----------

Httpdoc is currently limited to Rails applications. I plan to generalize the internals to support Sinatra and other frameworks, which should be quite trivial.

Since Httpdoc does not read Rails routes, it currently requires per-action URL paths to be explicitly written out in the documentation strings. I will be working on route inference.

For historic reasons, only Textile and HTML is supported in documentation fragments. I plan to phase out Textile and make Markdown the default format.

Format
------

The documentation format is vaguely inspired by JavaDoc conventions.

All documentation comments are indicated by double hashes, like so:

    ## This line introduces a documentation comment, and
    # this line continues it.

This first part of the documentation comment is the main description of the class or action.

Attributes consist of a key and a value:

    # @foo Bar

Here, `foo` is an attribute, and `Bar` is its value. Attributes can have multi-line values; a value ends when the next attribute starts or the entire documentation comment terminates.

Some attributes take two arguments, such as in the case of `param`:

    # @param key Some key.
    
Here, `key` is a parameter name, `Some key` is its description. See below.

A controller class is preceded by a block which introduces the controller:

    ## This API does stuff.
    class StuffController < ApplicationController
    
A controller class supports two attributes, `title` and `url`:

* `@title [title]`: specify a heading for the API itself.
    
* `@url [url]`: a base URL or relative path for the API. This is combined with the `--base-url` option passed to Httpdoc on the command line. Currently Httpdoc does not infer this stuff from Rails routes, so it can be overridden here if the controller name does not match the actual path used.

For example:

    ## This API does stuff.
    #
    # @title Stuff
    # @url http://stuff.ly/api/
    #
    class StuffController < ApplicationController

Methods are described thusly:

    ## Create stuff that can be shared with other users.
    #
    def create
      ...
    end
    
Methods support the following attributes:

* `@param [name] [description]`: which describes a parameter name.

* `@status [code] [description]`: describes a possible HTTP status code and its meaning.

* `@return [description]`: says what the action produces in terms of output.

* `@short [description]`: specifies a short description, usable as a title.

* `@url [url]`: specifies the URL of the HTTP call, either an absolute URL or a relative path. This is combined with the `@url` attribute on the class itself, and the `--base-url` option passed to Httpdoc on the command line. Currently Httpdoc does not infer this stuff from Rails routes, so it can be overridden here if the controller name does not match the actual path used. If not specified, the name of the method itself is assumed.

* `@example`: introduces an example block. It's terminated with an `@end` attribute. Within the example block, `@request` introduces the request, and `@response` the response.

Here's a complete example of a method doc:

    ## Create stuff that can be shared with other users.
    #
    # @url create/:amount
    # @short Create stuff
    # @param amount The amount of stuff to create, an integer between 3 and 42.
    # @return The URL to the stuff.
    # @status 201
    # @status 403 If you do not have permission to create the stuff.
    # @example
    #   @request
    #   POST #{base_url}/create/31
    #   
    #   @response
    #   HTTP/1.1 201 Created
    #   Content-Type: text/plain; charset=utf-8
    #
    #   http://#{base_url}/stuff/9953
    # @end
    #
    def create
      ...
    end

Usage
-----

To generate documentation for a bunch of controllers:

    httpdoc --base-url=http://mysite.com/api/v2/ --template=mytemplate --output-dir=doc/ app/controllers/api/v2/*.rb

Look in the `examples` directory for an example controller and its pre-generated documentation example. To generate the example controller's documentation, using the example template:

    httpdoc -t examples/single_file_template.erb -o examples/ examples/*.rb
    
Requirements
------------

* RedCloth
