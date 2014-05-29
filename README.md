Charge
------

[![npm](http://img.shields.io/npm/v/charge.svg?style=flat)](https://badge.fury.io/js/charge) [![tests](http://img.shields.io/travis/carrot/charge/master.svg?style=flat)](https://travis-ci.org/carrot/charge) [![coverage](http://img.shields.io/coveralls/carrot/charge.svg?style=flat)](https://coveralls.io/r/carrot/charge) [![dependencies](http://img.shields.io/gemnasium/carrot/charge.svg?style=flat)](https://gemnasium.com/carrot/charge)

A collection of useful middleware and tools for serving static sites.

> **Note:** This project is in early development, and versioning is a little different. [Read this](http://markup.im/#q4_cRZ1Q) for more details.

### Why should you care?

If you are serving a static site through node, we all know you can use [connect](https://github.com/senchalabs/connect) or [express](https://github.com/visionmedia/express)'s static serving capabilities. In both cases, this is actually the [serve-static](https://github.com/expressjs/serve-static) module behind the scenes. And while this does a wonderful job of quickly serving up a directory, for those heavily using static sites in production, there are many other utilities still to be desired. For example, imagine if:

- You didn't have to use `.html` at the end of each url
- You could add in custom routes and redirects (very handy for SPA)
- You could slot in a custom error page if there was a 404
- You could easily add http basic auth for a site in staging mode
- You could tightly control browser cacheing
- You could make certain files are inaccessible via the server, but still exist in the project
- You could inject a piece of markup or a script into any page before it's served

All of these things would be great, but are conveniences you usually expect from a dynamic, not a static site. These are just some of the capabilities of charge, a server for those who are serious about static sites.

### Installation

`npm install charge -g`

### Usage

Charge is represented by three different interfaces, each of which can be utilized independently or together. The charge module itself is a function that you can either access pieces of middleware from, or execute to generate a decorated connect instance. The decorated connect instance can be passed in to `http.createServer` as you usually would do with connect, or you can call a `start` function on it, which will create and start a server for you and decorate it with a few additional methods intended for working with websockets. This might sound confusing at first, but there is a diagram below as well as detailed explanations of each level that will make this more clear :grinning:.

<p align='center'><img src='https://i.cloudup.com/RaCXxJFoPn.svg' alt='charge structure' /></p>

Now we'll review each level with a little more detail!

The `charge` module itself is a function you can call to get a decorated connect instance, as you know. But you can also access each of the middleware packages charge uses on the module itself if you'd like to use and configure them entirely on your own. For example:

```js
var charge = require('charge');

charge.hygienist
charge.pathologist
charge.escapist
charge.publicist
charge.archivist
charge.minimist
charge.journalist
charge.columnist
charge.alchemist
charge.apologist
```

Each of these are middleware functions, compatible with [connect](http://www.senchalabs.org/connect/), [express](http://expressjs.com/4x/api.html#middleware) and similar middleware stacks. More details on each piece of middleware below:

- [Hygienist](https://github.com/carrot/hygienist-middleware) (clean urls)
- [Pathologist](https://github.com/carrot/pathologist-middleware) (custom routes)
- [Escapist](https://github.com/carrot/escapist-middleware) (ignore files)
- [Publicist](https://github.com/carrot/publicist-middleware) (basic auth)
- [Archivist](https://github.com/carrot/archivist-middleware) (cache control)
- [Minimist](https://github.com/expressjs/compression) (gzip content)
- [Journalist](https://github.com/samccone/infestor) (inject content)
- [Columnist](https://github.com/expressjs/morgan) (logging)
- [Alchemist](https://github.com/carrot/alchemist-middleware) (static file server)
- [Apologist](https://github.com/carrot/apology-middleware) (custom error pages)

You can also call `charge` function, which returns a `connect` instance with all the middleware described previously already added. The function takes a `root` path and an options object which represents options for each of the middleware merged together. As is the case with any connect object, you can pass this to `http.createServer` to create a server:

```js
var charge = require('charge'),
    http = require('http');

// the charge function returns a connect instance, so you can add more
// middleware or do anything else you would with a connect app here if you want
var app = charge('/path/to/public', { option: 'value' });
app.use(some_other_middleware);

http.createServer(app).listen(1111);
```

#### Options

Charge accepts options for each piece of middleware that it unifies (which is a bunch). Since this can end up being a large options object, you can alternately structure your options in a json file that you pass as a string. Below is an example of a json object representing all of the possible options:

```js
{
  "clean_urls": true,
  "spa": true,
  "error_page": "error.html",
  "auth": "username:password",
  "exclude": ['some_file', '*/another.file'],
  "cache_control": { '**': 3600000 },
  "routes": { "**": "index.html" },
  "write": { content: "hello!" },
  "url": "/static",
  "gzip": true,
  "log": "tiny"
}
```

To load a file like this, you can pass the path as a second argument to `charge` instead of an object. Alternately, you can name the file `charge.json`, and if it's in the same directory as the project root, it will be loaded automatically. Below is an example of manually loading a custom path:

```js
var app = charge('./public', '/path/to/config.json' );
```

All the options the charge takes are interoperable with [divshot.io's configuration interface](http://docs.divshot.com/guides/configuration) so that it can be seamlessly deployed to their wonderful static hosting environment. In addition, if you name your config file either `superstatic.json` or `divshot.json`, it will also be auto-loaded.

For the most up-to-date reference of options for each middleware be sure to check out their [individual project repos](#middleware-stack).

> **Note:** if you attempt to use `journalist` to write content into your response, we will automatically turn off gzip.

You can also start a new server using `app.start`, which will create and start a server for you and return a decorated node http server instance.

```js
var app = charge('path/to/public');
var server = app.start(); // you can pass a port as an argument, or it defaults to 1111
```

This decorated server will also initialize websockets and exposes a couple additional events and methods, documented below:

##### server.send(message)
Sends a string or object of your choice via websockets. If you pass an object, it will be stringified, so you'll want to run it through `JSON.parse` on the other end. You can add a websocket listener at `ws://host` (or `wss://host` if https) to recieve these messages. If you have multiple windows or devices open to the same page, charge keeps track of all sockets and sends messages to all of them.

##### server.sockets
An array of all sockets that are open with connected clients. Each of the sockets conform to [this api](https://github.com/faye/faye-websocket-node#websocket-api), if you are looking for very tight control.

##### server.on('client_open', fn)
Fired when a socket connection is established between a client and the server. This can happen multiple times.

##### server.on('client_close', fn)
Fired when a socket connection is disconnected by the client. This can happen multiple times.

##### server.on('message', fn)
Fired when a message is sent from the client to the server. The callback function takes one param which is the full message object sent by websockets. The message sent from the client can be accesed with the `data` property.

### Using Websockets

Getting websockets set up can be a little confusing if you've never done it before. Luckily, charge abstracts away as much as is possible -- it's simple to send any message you need to any number of connected sockets using the `send` method seen above. All you need to do is configure your client-side javascript to recieve the messages, which is unfortunately something that charge cannot make any easier for you. However, you can see a simple example of a functional socket setup [here](examples/websockets).

### Command Line Interface

Using charge from the command line will use all the default settings and fire up a server in either the current working directory or a path if provided as a positional argument. For example:

```
$ charge # starts a server in `pwd`
$ charge /path/to/project # starts a server at the provided path
```

Since charge has the ability to take a lot of options, it might be best to utilize the [configuration file option](#options) when running from the command line. It is not possible to configure each option through command line flags, so if you do want to load extra config, this is the only way to do it. Note that if you have an auto-loaded config file (`charge.json`, `superstatic.json`, or `divshot.json`), you do not need to pass a config file option, it will be auto-loaded as expected.

Charge, of course, also plays nicely with [Foreman](https://github.com/ddollar/foreman) (and it's equivalents). For example, your `Procfile` might look something like this:

```
# Procfile
web:   charge public -c config.json
redis: redis-server
```

##### CLI Options

```
--config, -c: path to a custom configuration file
--port, -p: port to start the server on, default 1111
```

### Acknowledgements

Charge was enormously inspired by [Divshot.io's](http://divshot.io/) excellent [Superstatic](http://github.com/divshot/superstatic) Project. They deserve to be commended for making that project, which is core to their business, open-source and being open to outside input.

In keeping with that spirit, we've done our best to make Charge interop, wherever possible, with [Divshot.io](http://divshot.io) so you can easily use them as your preferred static host.

### License & Contributing

- Details on the license [can be found here](LICENSE.md)
- Details on running tests and contributing [can be found here](contributing.md)
