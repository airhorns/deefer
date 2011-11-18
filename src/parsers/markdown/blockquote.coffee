require 'blank_line'
require 'eob'

Markdown.BLOCKQUOTE_START = new RegExp("^#{Markdown.OPT_SPACE}> ?")

Markdown::parseBlockquote = ->
  result = @src.scan(Markdown.PARAGRAPH_MATCH)
  while !@src.match?(Markdown.LAZY_END)
    result += @src.scan(Markdown.PARAGRAPH_MATCH)

  result = result.replace(Markdown.BLOCKQUOTE_START, '')
  el = @newBlockEl('blockquote')
  @tree.children.push el
  @parseBlocks(el, result)
  true
Markdown.define_parser('blockquote', Markdown.BLOCKQUOTE_START)
