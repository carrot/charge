fs        = require 'fs'
path      = require 'path'
http      = require 'http'
extend    = require 'lodash.assign'
connect   = require 'connect'
m         = require './middleware'

###*
 * The main function, given a root and options, returns a decorated connect
 * instance pre-loaded with selected middleware.
 *
 * @param  {String} root - the root of the project to be served
 * @param  {*} opts - string, object, or undefined, described below
 * @return {Function} an instance of connect
###

charge = (root, opts) ->
  root = path.resolve(root)
  opts = defaults parse_options(root, opts),
    clean_urls: false

  if opts.root then root = path.resolve(opts.root)

  app = connect()

  if opts.clean_urls    then app.use(m.hygienist(root))
  if opts.routes        then app.use(m.pathologist(opts.routes))
  if opts.exclude       then app.use(m.escapist(opts.exclude))
  if opts.auth          then app.use(m.publicist(opts.auth))
  if opts.cache_control then app.use(m.archivist(opts.cache_control))
  if opts.write         then app.use(m.journalist(opts.write))

  app.use(m.alchemist(root, { url: opts.url, gzip: opts.gzip }))
  app.use(m.apologist(root, opts.error_page))

  return app

###*
###*
 * The options param can accept a number of different types of input.
 *
 * - A string will be treated as a path to load json config from
 * - An object will be treated as a straight options object
 * - Undefined will try to load from default config paths, default to {}
 *
 * This method takes the direct options arg and parses whatever is given into
 * an object or throws an error if there's an invalid type passed.
 *
 * @private
 * @param  {String} root - charge project root
 * @param  {*} opts - options argument
 * @return {Object} parsed options object
###

parse_options = (root, opts) ->
  exists = (name) -> fs.existsSync(path.resolve(root, name))
  load_json = (name) -> require(path.resolve(root, name))

  return switch typeof opts
    when 'string' then load_json(opts)
    when 'object' then opts
    when 'undefined'
      do ->
        if exists('charge.json') then return load_json('charge.json')
        if exists('superstatic.json') then return load_json('superstatic.json')
        if exists('divshot.json') then return load_json('divshot.json')
        {}
    else throw new Error('invalid options')

module.exports = charge
###*
 * @exports hygienist
 * @exports escapist
 * @exports archivist
 * @exports alchemist
 * @exports apologist
 * @exports publicist
 * @exports pathologist
 * @exports journalist
###

extend(module.exports, m)
