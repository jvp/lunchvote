Template.header.events
  'keyup input#restaurant-search': _.throttle (e) ->
      e.preventDefault()
      text = $(e.target).val().trim();
      Session.set("searchText", text)
    , 200
  'submit form': (e) ->
    e.preventDefault()
    # just handle, does nothing
