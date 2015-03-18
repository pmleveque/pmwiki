window.Pmwiki =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
    window.router = new Bibliotheca.Routers.FichesRouter(
      {tiles: window.tiles}
    )

    #Backbone.history.start({pushState: true})

$(document).ready ->
  Pmwiki.initialize()
