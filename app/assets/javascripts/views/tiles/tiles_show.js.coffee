class Pmwiki.Views.TilesShow extends Backbone.View
  #template: JST["backbone/templates/tiles/show"]
  template: JST['tiles/index']

  tagName: "div"

  initialize: ->
    _.bindAll this, 'markAsModified', 'markAsSynced'

    @model.bind "markAsModified", @markAsModified
    @model.bind "markAsSynced", @markAsSynced

    # NB: use "=>" to keep the same "this" inside the function
    @model.on "all", (event) =>
      console.log @model.id, "event", event, this
    @model.on "change:text", =>
      if @model.hasChanged "text"
        @model.trigger "markAsModified"
    @model.on "sync", =>
      @model.trigger "markAsSynced"
    @model.on "scrollTo", =>
      $.scrollTo(@$el, 300, {offset: -20})


  markAsModified: ->
    @$el.css("border-color", "red")
    @model.modified = true

  markAsSynced: ->
    @$el.animate({"border-color":"white"}, 500).animate({"border-color":"silver"}, "slow")
    @model.modified = false

  events:
    "click .destroy" : "destroy"
    "click .save" : "save"
    "click .move" : "move"
    "click .close" : "close"
    "click .prev" : "previousTile"
    "click .next" : "nextTile"
    "click .sanitize" : "sanitize"
    "blur article" : "updateDescriptionAttribute"
    "keyup article" : "updateDescriptionAttribute"
    "paste article" : "updateDescriptionAttribute"
    "dblclick article a" : "annotate"
    "click article a" : "gotolink"
    "keypress article" : "specialKeys"
    # "focus article" : "edit"

  previousTile: (event) =>
    event.preventDefault()
    router.show router.tiles.get(-1 + @model.id), "before", @$el

  nextTile: (event) =>
    event.preventDefault()
    router.show router.tiles.get(1 + @model.id), "after", @$el

  gotolink: (event) ->
    event.preventDefault()
    event.stopPropagation()
    if (event.target.pathname.match(/tiles\/[0-9]+/))
      router.navigate event.target.pathname, {trigger: true}
    if (event.target.pathname.match(/summa\/[0-9]+/))
      router.navigate event.target.pathname, {trigger: true}


  annotate: (event) ->
    event.preventDefault()
    if (event.target.pathname.match(/tiles\/[0-9]+/))
      tileId = event.target.pathname.match(/[0-9]+/)[0]
      tile = router.tiles.get(tileId)

      setTimeout () ->
        # Il y a deux éléments:
        # 1) Le lien dans la tile à annoter: event.target !!!! pas utilisé pour l'instant
        # 2) La tile vers laquelle pointe le lien, à aftiler latéralement: tile
        router.addNote(tile, event.target)
      , 300

  updateDescriptionAttribute: () ->
    textValue = @$el.find("article:first").html()
    if @model.get("text") == textValue
      return false
    else
      @model.set "text", textValue
      localStorage.setItem(@model.id, textValue)
      localStorage.setItem("lastmodified", @model.id)
      return true

  save: (event) ->
    event.preventDefault()
    @model.save()
    localStorage.setItem("ids", localStorage.getItem("ids") + ",#{@model.id}")

  # reset: (event) ->
  #   event.preventDefault()
  #   @model.fetch
  #     success: (model, response) ->
  #       console.log("Successfully fetched")
  #     error: (model, response) ->
  #       console.error(response)

  move: (event) =>
    event.preventDefault()
    if @$el.parent().attr("id") is "container"
      @$el.appendTo("#notes")
    else
      @$el.appendTo("#container")
      @model.trigger("scrollTo")

  close: (event) ->
    event.preventDefault()
    @model.displayed = false
    @remove()

  destroy: (event) ->
    event.preventDefault()
    @model.destroy()
    @remove()

  sanitize: (event) =>
    event.preventDefault()
    @$el.find("span.Apple-style-span").contents().unwrap()
    @$el.find("span.Apple-style-span").remove()
    @$el.find("p").contents().unwrap()
    @$el.find("p").remove()
    @$el.find("[style]").removeAttr("style")
    @$el.find("[href]").each ->
      $(this).attr("href", $(this).attr("href").replace("http://0.0.0.0:3000",""))
    #.sub("http://0.0.0.0:3000/concepts#/","/tiles/")
    @$el.css("border-color", "red")
    textValue = @$el.find("article:first").html()
    @model.set "text", textValue
    @model.modified = true

  specialKeys: (e) ->
    # pour connaître le code (@=64; #=35; $=36; §=167; &=38; €=8364; ª=170; %=37)
    # $('body').keypress(function(e){
    #   console.log('keypress',  e.which );
    # });

    #// http://jsbin.com/atike/40/edit#javascript,html,live
    saveSelection = ->
      sel = window.getSelection()
      if (sel.getRangeAt && sel.rangeCount)
        ranges = []
        for i in [0..(sel.rangeCount-1)]
          ranges.push(sel.getRangeAt(i))
        # for (i = 0, len = sel.rangeCount; i < len; ++i)
        #   ranges.push(sel.getRangeAt(i));
        return ranges

    restoreSelection = (savedSel) ->
      if (savedSel)
        sel = window.getSelection()
        sel.removeAllRanges()
        for item in savedSel
          sel.addRange(item)
        # for (i = 0, len = savedSel.length; i < len; ++i)
        #   sel.addRange(savedSel[i])

    if (e.which == 13)
      document.execCommand('insertHTML', true, '\n')
      return false

    if (e.which == 62)
      document.execCommand('insertHTML', true, '\t')
      return false

    if (e.which == 64 or e.which == 170 or e.which == 35 or e.which == 167 or e.which == 37)
      console.log(e.which)

      # Disable events
      @undelegateEvents()
      # $("body").unbind('keypress')

      savedSel = saveSelection()
      htmlToBeInserted = "<input style='width:0' type='text'  autocorrect='off' autocapitalize='none' contenteditable='false' id='autocomplete_input' />"
      document.execCommand('insertHTML', true, "<a id='inputplace'>-</a>")

      $("#inputplace").html(htmlToBeInserted)

      thisView = this

      $("#autocomplete_input").animate({width: 120}).autocomplete
        minLength: 1
        autoFocus: true
        source:  router.tiles.map (tile) ->
          return { value: tile.get("title"), id: tile.id }

        select: ( event, ui ) ->
          $("#autocomplete_input").autocomplete("destroy")
          $("#inputplace").remove()

          restoreSelection(savedSel)
          newlink = $("<a href='##{ui.item.id}' contenteditable='false'>#{ui.item.value}</a>")
          document.execCommand('insertHTML', true, newlink.sanitizeLink().wrap("<div>").parent().html())

          # Enable events
          thisView.delegateEvents()
          # Unbind "$" keypress
          $("body").unbind 'keypress'

          return true


      $("#autocomplete_input").focus()
      $("#autocomplete_input").autocomplete "search", String.fromCharCode(e.which)

      $("body").bind 'keypress', (e) ->
        if (e.which == 8226 or e.which == 36) # "•" ou "$"
          e.preventDefault()

          #NOUVELLE FICHE si "$" !!!
          router.tiles.newWithExpression($("#autocomplete_input").val()) if (e.which == 36)

          $("body").unbind('keypress')
          $("#autocomplete_input").autocomplete("destroy")
          $("#inputplace").remove()
          restoreSelection(savedSel)

          # Enable events
          thisView.delegateEvents()

          return false
      return false

  render: ->
    # if localStorage !!
    if localStorage.getItem(@model.id)
      @model.set "text", localStorage.getItem(@model.id)
    $(@el).attr('id', "#{@model.id}").addClass('tile').html(@template(@model.toJSON() ))
    @$("article a, .related_tiles a").sanitizeLink()
    return this