class Pmwiki.Models.Tile extends Backbone.Model
  paramRoot: 'tile'

  url: () ->
    base = '/tiles'
    if @isNew()
      return base
    else
      return base + "/" + @id

  defaults:
    id: null
    title: null
    text: null
    displayed: false
    modified: false