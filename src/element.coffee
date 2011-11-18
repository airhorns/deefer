class Element
  @CATEGORIES: {}

  for k in ['blank', 'p', 'header', 'blockquote', 'codeblock', 'ul', 'ol', 'dl', 'table', 'hr']
    @CATEGORIES[k] = 'block'

  for k in ['text', 'a', 'br', 'img', 'codespan', 'footnote', 'em', 'strong', 'entity', 'typographic_sym', 'smart_quote', 'abbreviation']
    @CATEGORIES[k] = 'span'

  constructor: (@type, @value, @attributes = {}, @options = {}) ->
    @children = []

  category: ->
    @constructor.CATEGORIES[@type] || @options.category

module.exports = Element
