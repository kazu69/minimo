minimo
-------

> Mini Mock server
> Rack based REST corresponding server

Install
========

```ruby
gem install minimo
```

Usage
======

It is placed in the directory you specify a response file.
For example, in the case of the json response to the POST method.
To place the json file in ```response/POST/hello/world.json```.

```sh
$ mkdir -p response/POST/hello
$ cd response/POST/hello
$ vi world.json

{
    "hello": "world"
}
```

To start the minimo server.

```ruby
# initialize.rb
require 'minimo'

# set response file dir
set :fixture_path, File.dirname( __FILE__ ) + '/response'

# set log file dir
set :log_dir, File.dirname( __FILE__ ) + '/log'

# set http header
set :headers, { 'Vary' => 'Accept-Encoding' }

Rack::Handler::WEBrick.run minimo::Application, Port: 9292
```

And run the POST method.

```sh
$ curl -X POST http://localhost:9292/hello/world/ -d "{ hey: 'ok' }"
{
    "hello": "world"
}
```

You can check the log file

```sh
$ cat log/minimo.log

- -> /hello/world/
::1 - - [14/Jul/2016:21:45:17 JST] "POST /hello/world/ HTTP/1.1" 201 16
```

### Other

The response can be created json, xml, in the text.
In addition to the POST, HEAD, PUT, corresponds to DELETE.

```sh
# To place the response file in response/GET/hello/world.(txt|jso|xml)
# http status 200
$ curl -X GET http://localhost:9292/hello/world/

# To place the response file in response/HEAD/hello/world.(txt|jso|xml)
# http status 200
$ curl -I http://localhost:9292/hello/world/

# To place the response file in response/PUT/hello/world.(txt|jso|xml)
# http status 204
$ curl -X PUT http://localhost:9292/hello/world/

# To place the response file in response/DELETE/hello/world.(txt|jso|xml)
# http status 204
$ curl -X DELETE http://localhost:9292/hello/world/
```

Contributing
===============

Contributions to this gem are always welcome :smile:
See [CONTRIBUTING](https://github.com/kazu69/minimo/master/CODE_OF_CONDUCT.md) for more information on how to get started.

License
========

This project is licensed under the terms of the MIT license. See the [LICENSE](https://github.com/kazu69/minimo/master/LICENSE.txt) file.
