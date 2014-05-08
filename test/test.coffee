http = require 'http'

describe 'class', ->

  it 'should expose all middleware', ->
    charge.hygienist.should.be.a 'function'
    charge.escapist.should.be.a 'function'
    charge.archivist.should.be.a 'function'
    charge.journalist.should.be.a 'function'
    charge.alchemist.should.be.a 'function'
    charge.apologist.should.be.a 'function'
    charge.publicist.should.be.a 'function'

describe 'instance', ->

  before -> @app = charge(path.join(base_path, 'basic'))

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
