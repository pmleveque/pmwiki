class Pmwiki.Collections.Tiles extends Backbone.Collection
  model: Pmwiki.Models.Tile
  url: '/tiles.json'

  newWithExpression: (title) ->
    newTile = new Pmwiki.Models.Tile({title: title})
    @add newTile
    newTile.on "all", (event) ->
      console.log "newTile:event", event, this
    newTile.on "sync", ->
      # Insertion du nouveau lien
      newlink = $("<a href='/tiles/#{newTile.id}' contenteditable='true'>#{newTile.get 'title'}</a>")
      document.execCommand('insertHTML', true, newlink.sanitizeLink().wrap("<div>").parent().html())
      newTile.off "sync"

      # Affichage de la nouvelle tile en tant que note
      router.addNote(newTile, newlink)

    newTile.save()