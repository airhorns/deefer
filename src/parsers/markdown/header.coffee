require 'block_boundary'

Markdown.HEADER_ID = /(?:[ \t]\{#(\w[\w-]*)\})?/
Markdown.SETEXT_HEADER_START = new RegExp("^(#{Markdown.OPT_SPACE}[^ \t].*?)#{Markdown.HEADER_ID}[ \t]*?\n(-|=)+\s*?\n")

Markdown::parseSetextHeader = ->
  return false if !@afterBlockBoundary()
  @src.head += @src.getMatch().length
  [text, id, level] = [0,1,2].map (i) => @src.getCapture(i)
  text = text.trim()
  el = @newBlockEl('header', undefined, undefined, {level: (if level == '-' then 2 else 1), rawText: text})
  @addText(text, el)
  el.attr.id = id if id
  @tree.children.push el
  true

Markdown.defineParser 'SetextHeader', Markdown.SETEXT_HEADER_START

Markdown.ATX_HEADER_START = /^\#{1,6}/
Markdown.ATX_HEADER_MATCH = new RegExp("^(\#{1,6})(.+?)\s*?#*#{Markdown.HEADER_ID}\s*?\n")

Markdown::parseAtxHeader = ->
  return false if !@afterBlockBoundary()
  result = @src.scan(ATX_HEADER_MATCH)
  [text, id, level] = [0,1,2].map (i) => @src.getCapture(i)
  text.trim()
  el = @newBlockEl('header', undefined, undefined, {level: level.length, rawText: text})
  @addText(text, el)
  el.attr.id = id if id
  @tree.children.push el
  true
