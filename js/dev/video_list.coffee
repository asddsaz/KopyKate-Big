# video_list.coffee

class video_lister
  constructor: ->
    @max_videos=10
    #@last_max_videos=0
    @query_string=""
    @counter=1

  more_videos_yes: =>
    @max_videos+=10
    @counter=1
    @update()

  flush: (mode) =>
    if mode is "all"
      @max_videos=10
      @counter=1
    else
      @counter=1

  get_query: =>
    query_value = $("#search_bar").val()
    @query_string=query_value
    @flush("all")
    @update()

  linkify: (to, display, tag_class = "", tag_id = "", tag_style = "") =>
    link = "<a id='"+tag_id+"' href='?Video="+to+"'"
    if tag_class and tag_class != ""
      link += " class='"+tag_class+"'"
    if tag_style and tag_style != ""
      link += " style='"+tag_style+"'"
    if tag_id and tag_id != ""
      link += " style='"+tag_id+"'"
    link += ">" + display + "</a>"

    return link 

  link_click: =>
    console.log "Prevented page refresh..."

  seed_click: (inner_path) =>
    Page.cmd "fileNeed", inner_path + "|all", (res) =>
      console.log(res)
    return false

  update: =>
    console.log "[KopyKate: Updating video list]"
    query_string_no_space = @query_string.replace /\s/g, "%"
    query = "WHERE file.title LIKE '%" +query_string_no_space+ "%'"

    Page.cmd "dbQuery", ["SELECT * FROM file LEFT JOIN json USING (json_id) "+query+" ORDER BY date_added DESC"], (res1) =>
      Page.cmd "optionalFileList", {filter: "", limit: 1000}, (res2) =>

        $("#video_list").html ""
        $("#more_videos").html "<div class='more_videos text'>More videos!</div>"

        for row1, i in res1
          for row2, j in res2
            optional_inner_path = row2['inner_path']
            file_name = row2['inner_path'].replace /.*\//, ""
            file_seed = row2['peer_seed']
            file_peer = row2['peer']
            file_is_downloading = row2['is_downloading']
            optional_size = row2['bytes_downloaded']
            video_name = row1['file_name']
            video_title = row1['title']
            video_size = row1['size']
            video_brief = row1['description']
            video_image = row1['image_link']
            video_date_added = row1['date_added']
            video_user_address = row1['directory']
            video_channel_name = row1['cert_user_id'].split("@")[0]

            #i >= @last_max_videos
            if video_name is file_name and @counter < @max_videos

              file_seed_no_null = file_seed || 0

              if optional_size >= video_size
                size_display = Text.formatSize(video_size)
                seed_button_display = false
              else if file_is_downloading
                size_display = Text.formatSize(optional_size) + " / " + Text.formatSize(video_size)
                seed_button_display = false
              else if 0 < optional_size < video_size
                size_display = Text.formatSize(optional_size) + " / " + Text.formatSize(video_size)
                seed_button_display = true
              else
               size_display = Text.formatSize(video_size)
               seed_button_display = true

              video_string = video_date_added + "_" + video_user_address
              video_row_id = "row_" + @counter
              video_link_id = video_string

              video_row = $("<div></div>")
              video_row.attr "id", video_row_id
              video_row.attr "class", "video_row"

              video_thumbnail_id = "thumb_" + @counter
              video_thumbnail = $("<a></a>")
              video_thumbnail.attr "id", video_thumbnail_id
              video_thumbnail.attr "class", "video_thumbnail"
              video_thumbnail.css "background-image", "url('"+video_image+"')"
              video_thumbnail.attr "href", "?Video=" + video_string 

              video_info_id = "info_" + @counter
              video_info = $("<div></div>")
              video_info.attr "id", video_info_id
              video_info.attr "class", "video_info"

              video_link = @linkify(video_string, video_title, "video_link", video_string)

              video_peers_id = "peer_" + @counter
              video_peers = $("<div></div>")
              video_peers.attr "id", video_peers_id
              video_peers.attr "class", "video_brief"

              video_seed_button_id = "seed_" + @counter
              video_seed_button = $("<button></button>")
              video_seed_button.attr "id", video_seed_button_id
              video_seed_button.attr "class", "video_seed_button"
              video_seed_button.attr "value", optional_inner_path
              video_seed_button.text "+ SEED"

              video_peers_info = $("<span> Peers " + file_seed_no_null + " / " + file_peer + " - " + size_display + "</span>")

              user_info = $("<div></div>")
              user_info.attr "id", "user_info"
              user_info.attr "class", "video_brief"
              user_info.text video_channel_name.charAt(0).toUpperCase() + video_channel_name.slice(1) + " - " + Time.since(video_date_added)

              video_description = $("<div></div>")
              video_description.attr "id", "video_brief"
              video_description.attr "class", "video_brief"
              video_description.text video_brief

              $("#video_list").append video_row
              $("#" + video_row_id).append video_thumbnail
              $("#" + video_row_id).append video_info
              $("#" + video_info_id).append video_link
              $("#" + video_info_id).append user_info
              $("#" + video_info_id).append video_peers

              if seed_button_display
                $("#" + video_peers_id).append video_seed_button

              $("#" + video_peers_id).append video_peers_info
              $("#" + video_info_id).append video_description            
              $("#" + video_link_id).text video_title
              $("#" + video_link_id).on "click", ->
                Page.nav(this.href)
              $("#" + video_thumbnail_id).on "click", ->
                Page.nav(this.href)

              seed_click = @seed_click
              flush_page = @flush
              update_page = @update
              $("#" + video_seed_button_id).on "click", ->
                console.log("Seeding: " + this.value)
                seed_click(this.value)
                flush_page()
                update_page()

              @counter = @counter + 1

  render: =>
    query_value = $("#search_bar").val()
    @query_string=query_value
    video_list = $("<div></div>")
    video_list.attr "id", "video_list"
    video_list.attr "class", "video_list"
    #video_list.html "<div class='spinner'><div class='bounce1'></div><div class='bounce2'></div><div class='bounce3'></div></div>"

    footer = $("<div></div>")
    footer.attr "id", "footer"
    footer.attr "class", "footer"

    more_videos = $("<a></a>")
    more_videos.attr "id", "more_videos"
    more_videos.attr "class", "more_videos"
    more_videos.attr "href", "javascript:void(0)"

    $("#main").attr "class", "main"
    $("#main").html ""
    donav()
    #$("#main").attr "style", "width: calc(100% - 236.25px); margin-left: 236.25px"
    #$("#nav").show()
    $("#main").append video_list

    $("#main").append footer
    $("#footer").append more_videos
    $("#more_videos").html "<div class='spinner'><div class='bounce1'></div><div class='bounce2'></div><div class='bounce3'></div></div>" 

    more_videos_yes = @more_videos_yes
    $("#more_videos").on "click", ->
      $("#more_videos").html "<div class='spinner'><div class='bounce1'></div><div class='bounce2'></div><div class='bounce3'></div></div>" 
      more_videos_yes()     
  
    @update()

video_lister = new video_lister()
