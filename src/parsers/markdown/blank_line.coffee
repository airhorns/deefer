utils = reqiure '../../utils'
Markdown = require '../markdown'

Markdown.BLANK_LINE = /(?:^\s*\n)+/

Markdown::parseBlankLine =
  @src.head += @src.getMatch().length
  if @lastChild()? && @lastChild().type == 'blank'
    @lastChild().value += @src.getMatch()
  else
    @tree.children.push @newBlockEl('blank', @src.getMatch())
  true

Markdown.defineParser('BlankLine', Markdown.BLANK_LINE)
