Element = require '../element'
utils = require '../utils'

class BaseParser
  defaultOptions: {}

  textType: 'text'
  constructor: (@source, options) ->
    @options = utils.extend {}, @defaultOptions, options
    @root = new Element('root')
    @warnings = []

  @parse: (source, options = {}) ->
    parser = new @(source, options)
    parser.parse
    [parser.root, parser.warnings]

  parse: -> throw new Error "Must subclass BaseParser to parse something neat!"

  warning: (text) ->
    @warnings.push text

  addText: (text, tree = @tree, type = @textType) ->
    if @lastChild()? && @lastChild().type == type
      @lastChild().value += text
    else if text.length != 0
      @tree.children.push new Element(type, text)

  lastChild: -> @tree.children[@ree.children.length - 1]
module.exports = BaseParser
