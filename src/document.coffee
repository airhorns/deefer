utils = require 'utils'
Parsers = require 'parsers'

class Document
  defaultOptions: {}

  constructor: (source, options) ->
    @options = utils.extend {}, @defaultOptions, options

    if options.parser
      parser = options.parser
    else
      parserName = (options.input || 'markdown').to_s
      parserName = utils.camelize(parser)
      parser = Parsers[parserName]

    if parser?
      [@root, @warnings] = parser.parse(source, @options)
    else
      throw new Error("deefer has no parser to handle the specified input format: #{options.input}")
    end

module.exports = Document
