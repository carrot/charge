http       = require 'http'
net        = require 'net'
websocket  = require 'websocket-driver'
basic_path = path.join(base_path, 'basic')
opts_path  = path.join(base_path, 'options')

describe 'class', ->

  it 'should expose all middleware', ->
    charge.hygienist.should.be.a 'function'
    charge.escapist.should.be.a 'function'
    charge.archivist.should.be.a 'function'
    charge.journalist.should.be.a 'function'
    charge.alchemist.should.be.a 'function'
    charge.apologist.should.be.a 'function'
    charge.publicist.should.be.a 'function'

describe 'options', ->

  it 'should take a string and load from a json file', ->
    charge(basic_path, 'conf.json').stack.should.have.lengthOf(3)

  it 'should take an object', ->
    charge(basic_path, { clean_urls: true }).stack.should.have.lengthOf(3)

  it 'should load from a default config if no options provided', ->
    charge(path.join(base_path, 'charge-json')).stack.should.have.lengthOf(3)
    charge(path.join(base_path, 'superstatic-json')).stack.should.have.lengthOf(3)
    charge(path.join(base_path, 'divshot-json')).stack.should.have.lengthOf(3)

  it 'should have no options if no default configs present', ->
    charge(basic_path).stack.should.have.lengthOf(2)

  it 'should throw if invalid options passed', ->
    (-> charge(basic_path, false)).should.throw('invalid options')

  it 'should override root if root option is passed', ->
    charge(basic_path, { root: path.join(base_path, 'alt') }).stack.should.have.lengthOf(2)

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

  it 'should modify alchemist settings if url and/or gzip are passed', (done) ->
    app = charge(opts_path, 'alchemist.json')

    chai.request(app).get('/test').res (res) ->
      should.not.exist(res.headers['content-encoding'])
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

describe 'instance', ->

  before -> @app = charge(basic_path)

  it 'is an instance of connect', ->
    @app.should.be.a 'function'
    @app.use.should.be.a 'function'
    (=> http.createServer(@app)).should.not.throw()

  it 'should have all middleware attached', ->
    @app.stack.should.have.lengthOf(2)

  it 'should serve static files', (done) ->
    chai.request(@app).get('/').res (res) ->
      res.should.have.status(200)
      res.text.should.equal('<p>hello world!</p>\n')
      done()

  it 'should expose a start and stop method', (done) ->
    @app.start.should.be.a 'function'
    @app.start => @app.stop => @app.start => @app.stop(done)

  it 'should accept a custom port to the start method', (done) ->
    server = @app.start 1234, =>
      server._connectionKey.should.match(/1234$/)
      @app.stop(done)

describe 'websockets', ->

  it 'should throw if server hasnt been started', ->
    (-> charge(basic_path).send('wow')).should.throw('server not running')

  it 'should throw when send is called and websockets are disabled', ->
    app = charge(basic_path, { websockets: false })
    (-> app.send('wow')).should.throw('websockets disabled')

  it 'should connect and send a message via websockets', (done) ->
    app = charge(basic_path)

    app.start()
    driver = websocket.client('ws://localhost:1111/ws')
    tcp = net.createConnection(1111, 'localhost')

    tcp.pipe(driver.io).pipe(tcp)

    driver.messages.on 'data', (msg) ->
      msg.should.equal("{\"test\":\"wow\"}")
      done()

    tcp.on 'connect', =>
      driver.start()
      app.on 'connection', ->
        app.sockets.should.have.lengthOf(1)
        app.send({ test: 'wow' })
