path         = require 'path'
minimist     = require 'minimist'
antimatter   = require 'anti-matter'
EventEmitter = require('events').EventEmitter
charge       = require './'

module.exports = self = new EventEmitter

module.exports.run = (args) ->
  if typeof args is 'string' then args = args.split(' ')
  argv = minimist(args, alias: { config: 'c', port: 'p', help: 'h' })
  root = path.resolve(argv._[0] or process.cwd())
  app = charge(root, argv.config)

  if argv.help then return self.emit('data', help())

  app.start argv.port, ->
    self.emit('success', "server started on port #{argv.port || 1111}")

help = ->
  antimatter
    title: 'Charge Usage'
    options: { width: 64 }
    commands: [
      name: 'path'
      optional: ['--port, -p', '--config, -c']
      description: 'All arguments are optional. If you pass a [path] as the
      first positional argument, it will serve that path, otherwise it will
      serve cwd. The [port] and [config] options allow you to specify a port
      (default 1111) or config file (default charge.json)'
    ]
