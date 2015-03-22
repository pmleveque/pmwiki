class Pmwiki.Routers.TilesRouter extends Backbone.Router
  initialize: (options) ->
    @tiles = new Pmwiki.Collections.Tiles()
    # D'abord les tiles principales
    @tiles.reset options.tiles
    # Puis toutes les tiles
    # @todo explain what this.fetch() does
    @tiles.fetch
      success: () =>
        $("#afficher").autocomplete
          minLength: 3
          autoFocus: true
          source:  @tiles.map (tile) ->
            return { value: tile.get("title"), id: tile.id }

          select: ( event, ui ) =>
            @show(ui.item.id)
            $("#afficher").val("")

        # Get tiles that are saved locally
        # if localStorage.getItem("ids")
        #   localids = _.uniq(localStorage.getItem("ids").split(","))
        #   localids.push localStorage.getItem("lastmodified")

        #   router.addNote @tiles.get(1)

        #   $.each localids, () ->
        #     if this.valueOf() isnt "null"
        #       tile = router.tiles.get(this)
        #       link = $("<a>").attr("href","/tiles/#{this}").html(tile.get('title'))
        #       $("#5945 article").prepend("\n").prepend(link) unless $("#5945 article a[href='/tiles/#{tile.id}']").length > 0
        #       #router.show(tile.id)


    # @view = new Pmwiki.Views.TilesIndex(tiles: @tiles)
    # $("#tiles").html(@view.render().el)
    @index()

    $(".comment").on "mouseenter", (e) ->
      $(this).after("<span class='marker'>")

    $(".comment").on "mouseleave", (e) ->
      $(".marker").remove()

    $("#button_editmode").on "click", () ->
      switch $("#button_editmode").attr("value")
        when "x"
          router.editmode_a()
        when "a"
          router.editmode_c()
        when "c"
          router.editmode_a()

    # SAVE ALL
    $("#button_save").on "click", (e) ->
      $(".save").trigger "click"

    $("input[exec]").on "click", () ->
      document.execCommand($(this).attr("exec"))

    $("#button_comment").on "click", (e) ->
      # Disable events
      # @undelegateEvents()
      # savedSel = saveSelection()

      if $("#button_editmode").attr("value") is "a"
        document.execCommand('insertHTML', true, "<a id='inputplace'>-</a>")
        commentSpan = $("<span class='comment'></span>")
        commentSpan.insertAfter($("#inputplace"))
        $("#inputplace").remove()
        router.editmode_c()
        commentSpan.focus()


  routes:
    "tiles/new"  : "newTile"
    "tiles/"    : "index"
    "tiles/:id"  : "show"
    "summa/:p/:q/:a": "summaa"
    "summa/:p/:q"  : "summaq"
    ".*"      : "index"

  editmode_a: () ->
    $('#orInput').removeAttr("disabled").focus().blur().attr("disabled", "disabled");
    router.allowCommentEdit(false);
    router.allowArticleEdit(true);
    $("#button_editmode").attr("value", "a")

  editmode_c: () ->
    $('#orInput').removeAttr("disabled").focus().blur().attr("disabled", "disabled");
    router.allowCommentEdit(true);
    router.allowArticleEdit(false);
    $("#button_editmode").attr("value", "c")

  editmode_x: () ->
    $('#orInput').removeAttr("disabled").focus().blur().attr("disabled", "disabled");
    router.allowCommentEdit(false);
    router.allowArticleEdit(false);
    $("#button_editmode").attr("value", "x")

  articleEditRule: $("<style>article {-webkit-user-modify: read-write; -webkit-user-select: auto;} </style>")
  commentModifyRule: $("<style>span.comment {-webkit-user-modify: read-write; -webkit-user-select: auto;} </style>")

  allowCommentEdit: (status) ->
    if status
      $("body").append(@commentModifyRule)
    else
      @commentModifyRule.remove()

  allowArticleEdit: (status) ->
    if status
      $("body").append(@articleEditRule)
    else
      @articleEditRule.remove()

  summaParsCodes:
    1: "Iª"
    12: "Iª-II"
    22: "IIª-II"
    3: "IIIª"

  newTile: ->
    #@view = new Pmwiki.Views.Tiles.NewView(collection: @tiles)
    #$("#new-tile-view").html(@view.render().el)

  index: ->
    @addNote @tiles.get(1)
    #@view = new Pmwiki.Views.TilesIndex(collection: @tiles)

  summaq: (p,q) ->
    tile = @tiles.find (tile) =>
      tile.get("title").match("#{@summaParsCodes[p]} q#{q}:")
    router.navigate "/tiles/#{tile.id}", {trigger: true}

  summaa: (p,q,a) ->
    tile = @tiles.find (tile) =>
      tile.get("title").match("#{@summaParsCodes[p]} q#{q} a#{a}:")
    router.navigate "/tiles/#{tile.id}", {trigger: true}

  show: (id, position = "end", target = $("#container")) ->
    router.editmode_a()
    tile = @tiles.get(id)

    if tile?

      if not tile.displayed
        @view = new Pmwiki.Views.TilesShow(model: tile)
        switch position
          when "before"
            target.before(@view.render().$el)
          when "after"
            target.after(@view.render().$el)
          when "above"
            target.prepend(@view.render().el)
          when "end"
            target.append(@view.render().el)
        if @view.updateDescriptionAttribute()
          tile.save()


        # @view.$el.find("article:first").focus()
        tile.displayed = true

    #scroll
    # tile.trigger("scrollTo")

  addNote: (tile, link) ->
    if not tile.displayed
      @view = new Pmwiki.Views.TilesShow(model: tile)
      $("#notes").append(@view.render().el)
      @view.updateDescriptionAttribute()
      tile.displayed = true