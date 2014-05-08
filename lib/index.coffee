hygienist   = require 'hygienist-middleware'
escapist    = require 'escapist-middleware'
archivist   = require 'archivist-middleware'
alchemist   = require 'alchemist-middleware'
apologist   = require 'apology-middleware'
publicist   = require 'publicist-middleware'
# pathologist = require 'pathologist-middleware'
journalist  = require 'infestor'
connect     = require 'connect'

charge = (root, opts) ->
  root = path.resolve(root)
  return connect()
    .use(hygienist(root))
    # .use(pathologist())
    .use(escapist())
    .use(publicist())
    .use(archivist())
    .use(journalist())
    .use(alchemist(root))
    .use(apologist())

module.exports = charge

module.exports.hygienist   = hygienist
module.exports.escapist    = escapist
module.exports.archivist   = archivist
module.exports.journalist  = journalist
module.exports.alchemist   = alchemist
module.exports.apologist   = apologist
module.exports.publicist   = publicist
module.exports.pathologist = undefined
