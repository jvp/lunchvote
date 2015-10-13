Template.header.events
  'submit #restaurant-search': (e) ->
    console.log "here"
    e.preventDefault()
    text = e.target.text.value
    Session.set("searchText", text)
    e.target.text.value = ''
