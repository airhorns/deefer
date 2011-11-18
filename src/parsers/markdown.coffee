BaseParser = require 'base'
utils = require '../utils'
{StringScanner} = require("strscan")

class MarkdownParser extends BaseParser

  # Return the Data structure for the parser +name+.
  @parser: (name) ->
    @parsers[name]

  # Return +true+ if there is a parser called +name+.
  @hasParser: (name) ->
    @parsers[name]?

  @Data = class Data
    constructor: (@name, @startRe, @spanStart, @method) ->

  # Add a parser method
  #
  # * with the given +name+,
  # * using +start_re+ as start regexp
  # * and, for span parsers, +span_start+ as a String that can be used in a regexp and
  #   which identifies the starting character(s)
  #
  # to the registry. The method name is automatically derived from the +name+ or can explicitly
  # be set by using the +meth_name+ parameter.
  @defineParser: (name, startRe, spanStart, meth_name = "parse_#{name}") ->
    if @hasParser(name)
      throw new Error("A parser with the name #{name} already exists!")
    @parsers[name] = new Data(arguments...)

  # Regexp for matching indentation (one tab or four spaces)
  @INDENT: /^(?:\t| {4})/
  # Regexp for matching the optional space (zero or up to three spaces)
  @OPT_SPACE: /(?: ){0,3}/

  # Adapt the object to allow parsing like specified in the options.
  configureParser: ->
    @parsers = {}
    @blockParsers.concat(@spanParsers).forEach (name) ->
      if self.class.has_parser?(name)
        @parsers[name] = self.class.parser(name)
      else
        raise Kramdown::Error, "Unknown parser: #{name}"
      end
    end
    [@spanStart, @spanStartRe] = @spanParserRegexps()

  # Create the needed span parser regexps.
  spanParserRegexps: (parsers = @spanParsers) ->
    spanStart = parsers.map((name) -> @parsers[name].spanStart).join('|')
    [new RegExp(spanStart), new RegExp("(?=#{span_start})")]
  end

  parseBlocks: (element, text) ->
    @stack.push [@tree, @src, @blockIAL]
    @tree = el
    @src = if @src? then @src else new StringScanner(text)

    try
      while !@src.hasTerminated()
        blockIALSet = @blockIAL

        matched = false
        for name, blockParser of @blockParsers
          if @src.check(blockParser.start_re)
            matched = true
            @send(blockParser.method)

        if !matched
          warning('Warning: this should not occur - no block parser handled the line')
          addText @src.scan(/.+\n/)

        @blockIAL = nil if blockIALSet
      return true
    catch e
      return 'stop_block_parsing'
    finally
      [@tree, @src, @blockIAL] = @stack.pop()

  updateTree: (element) ->
    lastBlank = false
    newChildren = element.children.map (child) =>
      switch child.type
        when 'raw_text'
          lastBlank = false
          @resetEnv(new StringScanner(child.value), 'text')
          @parseSpans(child)
          child.children
        when 'eob'
          []
        when 'blank'
          if lastBlank
            lastBlank.value += child.value
            []
          else
            lastBlank = child
            child
        else
          lastBlank = false
          @updateTree(child)
          @updateAttrWithIAL(child.attr, child.options.ial) if child.options.ial
          child

    element.children = utils.flatten(newChildren)

  # Parse all span-level elements in the source string of @src into +el+.
  #
  # If the parameter +stop_re+ (a regexp) is used, parsing is immediately stopped if the regexp
  # matches and if no block is given or if a block is given and it returns +true+.
  #
  # The parameter +parsers+ can be used to specify the (span-level) parsing methods that should
  # be used for parsing.
  #
  # The parameter +text_type+ specifies the type which should be used for created text nodes.
  parseSpans: (el, stopRe, parsers, textType = @textType) ->
    @stack.push [@stree, @textType] if @tree?
    [@tree, @textType] = [el, textType]

    spanStart = @spanStart
    spanStartRe = @spanStartRe
    [spanStart, spanStartRe] = @spanParserRegexps(parsers) if parsers
    parsers = parsers || @spanParsers

    usedRe = if stopRe? then new RegExp("(?=#{stopRe|spanStart}")
    stopReFound = false

    while @src.hasFinished() and !stopReFound
      if result = @src.scanUntil(usedRe)
        addText(result)
        if stopRe and @src.check(stopRe)
          stopReFound = true
        unless stopReFound
          processed = false
          for name, parser of parsers
            if @src.check parser.startRe
              send(parser.method)
              processed = true
          if !processed && !stopReFound
            @addText(@src.scanChar())
      else
        unless stopRe
          @addText(@src.getRemainder())
          @src.terminate()
        break

    [@tree, @text_type] = @stack.pop()
    stopReFound

  resetEnv: (opts) ->
    utils.mixin @, {textType: 'raw_text', stack: []}, opts

  saveEnv: ->
    [@src, @tree, @blockIAL, @stack, @textType]

  restoreEnv: (env) ->
    [@src, @tree, @blockIAL, @stack, @textType] = env

  updateAttrWithIAL: (attr, ial) ->
    if ial.refs
      for ref in ial.refs
        @updateAttrWithIAL(attr, ref) if ref = @alds[ref]
    for k, v of ial
      if k == IAL_CLASS_ATTR
        attr[k] = (attr[k] || '') + " #{v}"
      else
        attr[k] = v

  # Create a new block-level element, taking care of applying a preceding block IAL if it
  # exists. This method should always be used for creating a block-level element!
  newBlockEl: (args...) ->
    el = new Element(args...)
    el.options.ial = @blockIAL if @blockIAL && !(el.type in ['blank', 'eob'])
    el

module.exports = MarkdownParser
