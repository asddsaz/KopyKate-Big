# profile_editor.coffee

class profile_editor
  render_box: =>
    $("#profile_editor").text "You have successfully logged in! ! !"
    $("#profile_editor_title").text "Your user name is:"    

  render: =>
    console.log("[KopyKate: Rendering profile editor.]")  
  
    container_editorbox = $("<div></div>")
    container_editorbox.attr "id", "container_editorbox"
    container_editorbox.attr "class", "editor" 
    
    profile_editorbox = $("<div></div>")
    profile_editorbox.attr "id", "profile_editor"
    #profile_editorbox.attr "class", "editor"
    
    title_peditorbox = $("<div></div>")
    title_peditorbox.attr "id", "profile_editor_title"
    #title_peditorbox.attr "class", "editor"
    
    user_peditorbox = $("<div></div>")
    user_peditorbox.attr "id", "profile_editor_user"
    user_peditorbox.text Page.site_info.cert_user_id
  
    $("#main").attr "class", "main_nomenu"
    $("#main").html ""
    donav()
    
    $("#main").append container_editorbox
    $("#container_editorbox").append profile_editorbox
    $("#container_editorbox").append title_peditorbox
    $("#container_editorbox").append user_peditorbox
    
    if Page.site_info
      if Page.site_info.cert_user_id
        # do something
        #$("#profile_editor").text "You have successfully logged in!"
        @render_box()
      else
        Page.cmd "certSelect", [["zeroid.bit"]], (res) =>
          # do something
          #$("#profile_editor").text "You have successfully logged in!"
          @render_box()
     else
       $("#profile_editor").text "Loading site info..."
    
profile_editor = new profile_editor()

