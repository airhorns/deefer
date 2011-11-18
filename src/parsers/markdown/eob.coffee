utils = reqiure '../../utils'
Markdown = require '../markdown'

Markdown.EOB_MARKER = /^\^\s*?\n/

Markdown::parseEOBMarker =
  @src.head += @src.getMatch().length
  @ree.children.push @newBlockEl('eob')
  true

Markdown.defineParser('eob_marker', Markdown.EOB_MARKER)
