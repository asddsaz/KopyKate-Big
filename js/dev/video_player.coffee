# video_player.coffee

class video_playing

  register_comment: (file_uri, body, date_added, cb) =>
    inner_path = "data/users/" + Page.site_info.auth_address + "/data.json"
    Page.cmd "fileGet", [inner_path, false], (res) =>
      if res
        res = JSON.parse(res)
      if res.comment is null
        res.comment = {}
      if res.comment[file_uri] is null or res.comment[file_uri] is undefined
        res.comment[file_uri] = []

      console.log(res.comment)
      console.log(file_uri)
      console.log(res.comment[file_uri])
      res.comment[file_uri].push({body: body, date_added: date_added})
      Page.cmd "fileWrite", [inner_path, Text.fileEncode(res)], cb

  write_comment: (file_date_added, file_directory, comment_body) =>    
    register_comment = @register_comment
    load_comments = @load_comments
    file_uri = file_date_added + "_" + file_directory
    editor.check_content_json (res) =>
      register_comment file_uri, comment_body, Time.timestamp(), (res) ->
        load_comments()
        Page.cmd "siteSign", {inner_path: "data/users/" + Page.site_info.auth_address + "/content.json"}, (res) ->
          Page.cmd "sitePublish", {inner_path: "data/users/" + Page.site_info.auth_address + "/content.json", "sign": false}

  load_comments: =>
    init_url = Page.history_state["url"]
    real_url = init_url.split("Video=")[1]

    video_date_added = real_url.split("_")[0]
    video_user_address = real_url.split("_")[1]
    file_uri = real_url

    query = "SELECT * FROM comment LEFT JOIN json USING (json_id) WHERE file_uri='" + real_url + "' ORDER BY date_added DESC"

    Page.cmd "dbQuery", [query], (res) =>

      comment_input = $("<input>")
      comment_input.attr "id", "comment_box_input"
      comment_input.attr "class", "comment_box_input"
      comment_input.attr "placeholder", "Write a comment..."

      comment_counter = 0
      $("#comment_actual").html ""
      $("#comment_actual").append comment_input

      write_comment = @write_comment
      $("#comment_box_input").on "keypress", (e) ->
        comment_body = this.value
        if e.which == 13
          if Page.site_info.cert_user_id
            write_comment video_date_added, video_user_address, comment_body
          else
            Page.cmd "certSelect", [["zeroid.bit"]], (res) =>
              write_comment video_date_added, video_user_address, comment_body

      for comment in res
        comment_body = comment.body
        comment_body = comment.body.replace /</g, ' < '
        comment_body = comment.body.replace />/g, ' > '
        comment_date_added = comment.date_added
        comment_directory = comment.directory
        comment_user_id = comment.cert_user_id.split("@")[0]
        comment_id = "comment_" + comment_date_added + "_" + comment_directory
      
        comment_single_id = "comment_" + comment_counter
        comment_single = $("<div></div>")
        comment_single.attr "id", comment_single_id
        comment_single.attr "class", "comment_single"
  
        comment_user = $("<div></div>")
        comment_user.attr "id", "comment_user"
        comment_user.attr "class", "comment_user"
        comment_user.text comment_user_id.charAt(0).toUpperCase() + comment_user_id.slice(1)

        comment_text = $("<div></div>")
        comment_text.attr "id", "comment_text"
        comment_text.attr "class", "comment_text"
        comment_text.text comment_body

        $("#comment_actual").append comment_single
        $("#" + comment_single_id).append comment_user
        $("#" + comment_single_id).append comment_text

        comment_counter = comment_counter + 1

  render: =>
    init_url = Page.history_state["url"]
    real_url = init_url.split("Video=")[1]
    
    date_added = real_url.split("_")[0]
    user_address = real_url.split("_")[1]

    video_player = $("<div></div>")
    video_player.attr "id", "video_player"
    video_player.attr "class", "video_player"

    video_box = $("<div></div>")
    video_box.attr "id", "video_box"
    video_box.attr "class", "video_box"

    video_info = $("<div></div>")
    video_info.attr "id", "player_info"
    video_info.attr "class", "player_info"

    comment_div = $("<div></div>")
    comment_div.attr "id", "comment_box"
    comment_div.attr "class", "player_info"

    comment_actual = $("<div></div>")
    comment_actual.attr "id", "comment_actual"
    comment_actual.attr "class", "comment_actual"

    query = "SELECT * FROM file LEFT JOIN json USING (json_id) WHERE date_added='" + date_added + "' AND directory='" + user_address + "'"
    Page.cmd "dbQuery", [query], (res1) =>
      Page.cmd "optionalFileList", {filter: "", limit: 1000}, (res2) =>
        my_row = res1[0]
        file_name = my_row['file_name']
        video_title = my_row['title']
        video_channel = my_row['cert_user_id'].split("@")[0]
        video_description = my_row['description']
        user_directory = my_row['directory']

        stats_loaded = false

        i = 0
        for my_file, i in res2
          optional_name = my_file['inner_path'].replace /.*\//, ""
          optional_peer = my_file['peer']
          optional_seed = my_file['peer_seed'] 

          if optional_name is file_name
            stats_loaded = true
            $("#player_info").append "<span class='video_player_title'>" + video_title + "</span>"
            $("#player_info").append "<span class='video_player_stats'>" + optional_seed + " / " + optional_peer + " peers</span>"
            $("#player_info").append "<span class='video_player_username'>" + video_channel.charAt(0).toUpperCase() + video_channel.slice(1) + "</span>"
            $("#player_info").append "<span class='video_player_brief'>" + video_description + "</span>"

        if i is res2.length
          if stats_loaded is false
            $("#player_info").append "<span class='video_player_title'>" + video_title + "</span><br>"
            $("#player_info").append "<span class='video_player_stats'>0 / 0 peers</span><br>"
            $("#player_info").append "<span class='video_player_username'>" + video_channel.charAt(0).toUpperCase() + video_channel.slice(1) + "</span><br>"
            $("#player_info").append "<span class='video_player_brief'>" + video_description + "</span>"   

        video_actual = $("<video></video>")
        video_actual.attr "id", "video_actual"
        video_actual.attr "class", "video_actual"
        video_actual.attr "src", "data/users/" + user_directory + "/" + file_name
        video_actual.attr "controls", true
        video_actual.attr "autoplay", true

        $("#video_box").append video_actual

    $("#main").attr "class", "main_nomenu"
    $("#main").html ""
    donav()
    #$("#nav").hide()
    #$("#main").attr "style", "width: 100%; margin-left: 0px"
    $("#main").append video_player
    $("#video_player").append video_box
    $("#video_player").append video_info
    $("#video_player").append comment_div
    $("#comment_box").append comment_actual

    @load_comments()

video_playing = new video_playing()
