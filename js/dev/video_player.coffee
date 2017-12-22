# video_player.coffee

class video_playing
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

    query = "SELECT * FROM file LEFT JOIN json USING (json_id) WHERE date_added='" + date_added + "' AND directory='" + user_address + "'"
    Page.cmd "dbQuery", [query], (res1) =>
      Page.cmd "optionalFileList", {filter: "", limit: 1000}, (res2) =>
        my_row = res1[0]
        file_name = my_row['file_name']
        video_title = my_row['title']
        video_channel = my_row['cert_user_id']
        video_description = my_row['description']
        user_directory = my_row['directory']

        for my_file, i in res2
          optional_name = my_file['inner_path'].replace /.*\//, ""
          optional_peer = my_file['peer']
          optional_seed = my_file['peer_seed'] 

          if optional_name is file_name
            $("#player_info").append "<span style='font-size: 17.5px'>" + video_title + "</span><br>"
            $("#player_info").append "<span style='color: #a8a8a8'>" + video_channel + "</span><br>"
            $("#player_info").append "<span style='color: #a8a8a8'>Peers - " + optional_seed + " / " + optional_peer + "</span><br>"
            $("#player_info").append "<span style='color: #a8a8a8'>" + video_description + "</span>"

        video_actual = $("<video></video>")
        video_actual.attr "id", "video_actual"
        video_actual.attr "class", "video_actual"
        video_actual.attr "src", "data/users/" + user_directory + "/" + file_name
        video_actual.attr "controls", true

        $("#video_box").append video_actual

    $("#main").attr "class", "main_nomenu"
    $("#main").html ""
    donav()
    #$("#nav").hide()
    #$("#main").attr "style", "width: 100%; margin-left: 0px"
    $("#main").append video_player
    $("#video_player").append video_box
    $("#video_player").append video_info

video_playing = new video_playing()
