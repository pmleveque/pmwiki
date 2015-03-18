window.Pmwiki =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
    window.router = new Pmwiki.Routers.TilesRouter(
      {tiles: window.tiles}
    )

    #Backbone.history.start({pushState: true})

$(document).ready ->
  Pmwiki.initialize()

$.fn.extend
  sanitizeLink: ->
    $.each $(this), (i, link) ->
      if !(typeof($(link).attr('href'))=='undefined')
        $(link).attr("href", $(link).attr("href").replace(/#/,"/tiles/"))
        $(link).removeAttr("contenteditable")
        if $(link).text().match(/@/)
          $(link).addClass("person")
        else if $(link).text().match(/§§/)
          $(link).addClass("text")
        else if $(link).text().match(/§/)
          $(link).addClass("book")
        else if $(link).text().match(/%/)
          $(link).addClass("me")
        else if $(link).text().match(/#/)
          $(link).addClass("category")

    return $(this)