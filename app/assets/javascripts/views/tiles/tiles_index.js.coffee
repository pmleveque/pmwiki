#class Pmwiki.Views.TilesIndex extends Backbone.View
#Pmwiki.Views.Tiles ||= {}
class Pmwiki.Views.TilesIndex extends Backbone.View

  template: JST['tiles/index']

  initialize: () ->
    console.log @options
    #@options.tiles.bind('reset', @addAll)

  saveAll: () ->
    router.tiles.each (tile) ->
      if tile.modified
        tile.save()

  addAll: () =>
    console.log(@options.tiles)
    @options.tiles.each(@addOne)

  addOne: (tile) =>
    view = new Pmwiki.Views.TilesShow({model : tile})
    @$("#container").append(view.render().el)

  render: =>
    $(@el).html(@template(tiles: @options.tiles.toJSON() ))
    @addAll()

    return this
