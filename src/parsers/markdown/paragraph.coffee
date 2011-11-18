utils = reqiure '../../utils'
Markdown = require '../markdown'
Element = require '../../element'

#Markdown.LAZY_END_HTML_SPAN_ELEMENTS = HTML_SPAN_ELEMENTS + %w{script}
#Markdown.LAZY_END_HTML_START = /<(?>(?!(?:#{LAZY_END_HTML_SPAN_ELEMENTS.join('|')})\b)#{REXML::Parsers::BaseParser::UNAME_STR})\s*(?>\s+#{REXML::Parsers::BaseParser::UNAME_STR}\s*=\s*(["']).*?\1)*\s*\/?>/m
#Markdown.LAZY_END_HTML_STOP = /<\/(?!(?:#{LAZY_END_HTML_SPAN_ELEMENTS.join('|')})\b)#{REXML::Parsers::BaseParser::UNAME_STR}\s*>/m

#Markdown.LAZY_END = /#{BLANK_LINE}|#{IAL_BLOCK_START}|#{EOB_MARKER}|^#{OPT_SPACE}#{LAZY_END_HTML_STOP}|^#{OPT_SPACE}#{LAZY_END_HTML_START}|\Z/

#Markdown.PARAGRAPH_END = /#{LAZY_END}|#{DEFINITION_LIST_START}/
#
Markdown.LAZY_END = new RegExp("#{Markdown.BLANK_LINE}|#{Markdown.EOB_MARKER}|^#{Markdown.OPT_SPACE}#{Markdown.LAZY_END_HTML_STOP}|^#{Markdown.OPT_SPACE}#{Markdown.LAZY_END_HTML_START}|\Z")
Markdown.PARAGRAPH_START = new RegExp("^#{Markdown.OPT_SPACE}[^ \t].*?\n")
Markdown.PARAGRAPH_MATCH = /^.*?\n/
Markdown.PARAGRAPH_END = LAZY_END

Markdown::parseParagraph = ->
  result = @src.scan(Markdown.PARAGRAPH_MATCH)
  while !@src.check(Markdown.PARAGRAPH_END)
    result += @src.scan(Markdown.PARAGRAPH_MATCH)
  result = result.trim()

  if @lastChild() && @lastChild.type == 'p'
    @lastChild().children[0].value += "\n" + result
  else
    @tree.children.push @newBlockEl('p')
    @lastChild().children.push new Element(@text_type, result)
  true

Markdown.defineParser 'Paragraph', PARAGRAPH_START
