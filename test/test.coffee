http       = require 'http'
net        = require 'net'
websocket  = require 'websocket-driver'
cli        = require '../lib/cli'
basic_path = path.join(base_path, 'basic')
opts_path  = path.join(base_path, 'options')

describe 'module', ->

  it 'should expose all middleware', ->
    charge.hygienist.should.be.a 'function'
    charge.escapist.should.be.a 'function'
    charge.archivist.should.be.a 'function'
    charge.journalist.should.be.a 'function'
    charge.alchemist.should.be.a 'function'
    charge.apologist.should.be.a 'function'
    charge.publicist.should.be.a 'function'
    charge.columnist.should.be.a 'function'

describe 'options', ->

  it 'should take a string and load from a json file', ->
    charge(basic_path, 'conf.json').stack.should.have.lengthOf(4)

  it 'should take an object', ->
    charge(basic_path, { clean_urls: true }).stack.should.have.lengthOf(4)

  it 'should load from a default config if no options provided', ->
    charge(path.join(base_path, 'charge-json')).stack.should.have.lengthOf(4)
    charge(path.join(base_path, 'superstatic-json')).stack.should.have.lengthOf(4)
    charge(path.join(base_path, 'divshot-json')).stack.should.have.lengthOf(4)

  it 'should have no options if no default configs present', ->
    charge(basic_path).stack.should.have.lengthOf(3)

  it 'should throw if invalid options passed', ->
    (-> charge(basic_path, false)).should.throw('invalid options')

  it 'should override root if root option is passed', ->
    charge(basic_path, { root: path.join(base_path, 'alt') }).stack.should.have.lengthOf(3)

  it 'should use clean urls if clean_urls is passed', (done) ->
    app = charge(opts_path, 'clean_urls.json')

    chai.request(app).get('/index.html').res (res) ->
      res.redirects[0].should.match /index$/
      done()

  it 'should exclude files if exclude is passed', (done) ->
    app = charge(opts_path, 'exclude.json')

    chai.request(app).get('/index.html').res (res) ->
      res.should.have.status(404)
      res.should.be.html
      done()

  it 'should use basic auth if auth is passed', (done) ->
    app = charge(opts_path, 'auth.json')

    chai.request(app).get('/').res (res) ->
      res.should.have.status(401)
      done()

  it 'should cache correctly if cache_control is passed', (done) ->
    app = charge(opts_path, 'cache_control.json')

    chai.request(app).get('/').res (res) ->
      res.headers['cache-control'].should.equal('wow')
      done()

  it 'should use custom routes if routes is passed', (done) ->
    app = charge(opts_path, 'routes.json')

    chai.request(app).get('/foobar.html').res (res) ->
      res.should.have.status(200)
      done()

  it 'should modify alchemist settings if url and/or gzip are passed', (done) ->
    app = charge(opts_path, 'alchemist.json')

    chai.request(app).get('/test').res (res) ->
      res.should.have.status(200)
      done()

  it 'should use a custom error page if error_page is passed', (done) ->
    app = charge(opts_path, 'error_page.json')

    chai.request(app).get('/foo').res (res) ->
      res.should.have.status(404)
      res.should.be.html
      res.text.should.equal("<p>flagrant error!</p>\n")
      done()

  it 'should inject content if write is passed', (done) ->
    app = charge(opts_path, 'write.json')

    chai.request(app).get('/infestor.html').res (res) ->
      res.should.have.status(200)
      res.should.have.be.html
      res.text.should.match /hello there!/
      done()

  it 'should gzip content if gzip is passed', (done) ->
    app = charge(opts_path, 'gzip.json')

    chai.request(app).get('/').res (res) ->
      res.headers['content-encoding'].should.equal('gzip')
      res.should.have.status(200)
      res.should.have.be.html
      res.text.should.equal('<p>wow</p>\n')
      done()

describe 'instance', ->

  before -> @app = charge(basic_path, { log: false })

  it 'is an instance of connect', ->
    @app.should.be.a 'function'
    @app.use.should.be.a 'function'
    (=> http.createServer(@app)).should.not.throw()

  it 'should have all middleware attached (except logging)', ->
    @app.stack.should.have.lengthOf(2)

  it 'should serve static files', (done) ->
    chai.request(@app).get('/').res (res) ->
      res.should.have.status(200)
      res.text.should.equal('<p>hello world!</p>\n')
      done()

  it 'should expose a start method', (done) ->
    @app.start.should.be.a 'function'
    server = @app.start =>
      server.close =>
        server2 = @app.start =>
          server2.close(done)

  it 'should accept a custom port to the start method', (done) ->
    server = @app.start 1234, =>
      server._connectionKey.should.match(/1234$/)
      server.close(done)

describe 'websockets', ->

  it 'should throw when send is called and websockets are disabled', (done) ->
    app = charge(basic_path, { websockets: false })
    server = app.start ->
      (-> server.send('wow')).should.throw('websockets disabled')
      server.close(done)

  it 'should connect and send a message via websockets', (done) ->
    # set up the client mock
    driver = websocket.client('ws://localhost:1111/ws')
    tcp = net.createConnection(1111, 'localhost')
    tcp.pipe(driver.io).pipe(tcp)

    # 1. start the server
    server = charge(basic_path).start()

    # 4. when the client gets the message, disconnect
    driver.messages.on 'data', (msg) ->
      msg.should.equal("{\"test\":\"wow\"}")
      driver.close()

    tcp.on 'connect', =>
      # 2. connect the client mock to the server
      driver.start()

      # 3. when the server detects the connected client, send it a message
      server.on 'client_open', ->
        server.sockets.should.have.lengthOf(1)
        server.send({ test: 'wow' })

      # 5. when the server detects a disconnected client, close the server
      server.on 'client_close', ->
        server.close ->
          server.sockets.should.have.lengthOf(0)
          done()

  it 'should send messages to multiple connected clients'

describe 'cli', ->

  it 'should run a server in the current directory', (done) ->
    cwd = process.cwd()
    process.chdir(path.join(base_path, 'basic'))

    cli.once 'success', ->
      chai.request('http://localhost:1111').get('/').res (res) ->
        res.should.have.status(200)
        res.text.should.equal("<p>hello world!</p>\n")
        process.chdir(cwd)
        server.close(done)

    server = cli.run([])

  it 'should run a server in a passed in directory', (done) ->
    cli.once 'success', (msg) ->
      msg.should.equal('server started on port 1111')
      chai.request('http://localhost:1111').get('/').res (res) ->
        res.should.have.status(200)
        res.text.should.equal("<p>hello world!</p>\n")
        server.close(done)

    server = cli.run(path.join(base_path, 'basic'))

  it 'should use a custom config file if --config is passed', (done) ->
    cli.once 'success', ->
      chai.request('http://localhost:1111').get('/index.html').res (res) ->
        res.should.have.status(200)
        res.redirects[0].should.match /index$/
        server.close(done)

    server = cli.run("#{path.join(base_path, 'basic')} -c conf.json")

  it 'should use a custom port if --port is passed', (done) ->
    cli.once 'success', ->
      chai.request('http://localhost:1234').get('/').res (res) ->
        res.should.have.status(200)
        server.close(done)

    server = cli.run("#{path.join(base_path, 'basic')} -p 1234")

  it 'should print help if --help is passed', (done) ->
    cli.once 'data', (msg) ->
      msg.should.match /Charge Usage/
      done()

    server = cli.run("--help")
