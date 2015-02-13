Template.lunchList.helpers
  lunches: () ->
    return Lunches.find {}, {sort: {votes: -1}}

Template.lunchList.rendered = ->
  $container = $('#lunches')
  $container.imagesLoaded(
    -> $container.masonry { itemSelector: '.lunch', isAnimated: true }
  )

Template.lunchList.events
  'click .upvote': (e) ->
    e.preventDefault()
    Meteor.call('vote', this._id)

Template.lunchList.helpers
  votedToday: () ->
    user = Meteor.user()
    if user && !_.include(votersToday(), user.username)
      return false
    else
      return true

@votersToday = ->
  lunches = Lunches.find {voted: true}
  votersToday = []
  votersToday.push.apply(votersToday, lunches.map (lunch) -> lunch.voters)
  return _.flatten(votersToday)
