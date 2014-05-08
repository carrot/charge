http = require 'http'
basic_path = path.join(base_path, 'basic')

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
    charge(basic_path, 'conf.json').stack.should.have.lengthOf(8)

  it 'should take an object', ->
    charge(basic_path, { clean_urls: true }).stack.should.have.lengthOf(8)

  it 'should load from a default config if no options provided', ->
    charge(path.join(base_path, 'charge-json')).stack.should.have.lengthOf(8)
    charge(path.join(base_path, 'superstatic-json')).stack.should.have.lengthOf(8)
    charge(path.join(base_path, 'divshot-json')).stack.should.have.lengthOf(8)

  it 'should have no options if no default configs present', ->
    charge(basic_path).stack.should.have.lengthOf(7)

  it 'should throw if invalid options passed', ->
    (-> charge(basic_path, false)).should.throw('invalid options')

describe 'instance', ->

  before -> @app = charge(basic_path)

  it 'is an instance of connect', ->
    @app.should.be.a 'function'
    @app.use.should.be.a 'function'
    (=> http.createServer(@app)).should.not.throw()

  it 'should have all middleware attached', ->
    @app.stack.should.have.lengthOf(7)

  it 'should serve static files', (done) ->
    chai.request(@app).get('/').res (res) ->
      res.should.have.status(200)
      res.text.should.equal('<p>hello world!</p>\n')
      done()
