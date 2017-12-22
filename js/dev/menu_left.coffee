# menu_left.coffee

class left_menuify
  render: =>
    menu_left = $("<div></div>")
    menu_left.attr "id", "menu_left"
    menu_left.attr "class", "menu_left"

    menu_left_items = $("<ul></ul>")
    menu_left_items.attr "id", "menu_left_items"
    menu_left_items.attr "class", "menu_left_items"

    item_head_version = $("<li></li>")
    item_head_version.attr "id", "item_head_version"
    item_head_version.attr "class", "list_item li_head"
    item_head_version.text "BETA v0.2.0"

    item_home = $("<li></li>")
    item_home.attr "id", "item_home"
    item_home.attr "class", "list_item li_home"

    item_home_link = $("<a></a>")
    item_home_link.attr "id", "item_home_link"
    item_home_link.attr "class", "item_link"
    item_home_link.attr "href", "?Home"
    item_home_link.text "Home"

    item_videobox = $("<div></div>")
    item_videobox.attr "id", "item_videobox"
    item_videobox.attr "class", "list_item li_videobox"

    item_videobox_link = $("<a></a>")
    item_videobox_link.attr "id", "item_videobox_link"
    item_videobox_link.attr "class", "item_link"
    item_videobox_link.attr "href", "?Box"
    item_videobox_link.text "VideoBox"

    item_seedbox = $("<div></div>")
    item_seedbox.attr "id", "item_seedbox"
    item_seedbox.attr "class", "list_item li_seedbox"
    
    item_seedbox_link = $("<a></a>")
    item_seedbox_link.attr "id", "item_seedbox_link"
    item_seedbox_link.attr "class", "item_link"
    item_seedbox_link.attr "href", "?Seed"
    item_seedbox_link.text "SeedBox"

    $("#nav").html ""
    $("#nav").append menu_left
    $("#menu_left").append menu_left_items
    $("#menu_left_items").append item_head_version
    $("#menu_left_items").append item_home
    $("#item_home").append item_home_link
    $("#menu_left_items").append item_videobox
    $("#item_videobox").append item_videobox_link
    $("#menu_left_items").append item_seedbox
    $("#item_seedbox").append item_seedbox_link
    $("#item_home_link").on "click", ->
      Page.nav(this.href)
    $("#item_videobox_link").on "click", ->
      Page.nav(this.href)
    $("#item_seedbox_link").on "click", ->
      Page.nav(this.href)
    
left_menuify = new left_menuify()
