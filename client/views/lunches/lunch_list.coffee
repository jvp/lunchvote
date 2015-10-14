Template.lunchList.helpers
  lunches: () ->
    searchText = Session.get('searchText')
    if searchText && searchText != ''
      searchQuery = new RegExp(searchText, "i")
      return Lunches.find {$or: [{restaurantName: {$regex: searchQuery}}, {lunchItemsString: {$regex: searchQuery}}]}, {sort: {votes: -1, restaurantScore: -1}}
    else
      return Lunches.find {}, {sort: {votes: -1, restaurantScore: -1}}
  votedToday: () ->
    user = Meteor.user()
    if user && !_.include(votersToday(), user.username)
      return false
    else
      return true

Template.lunch.helpers
  votedToday: () ->
    user = Meteor.user()
    if user && !_.include(votersToday(), user.username)
      return false
    else
      return true
  votersList: () ->
    if this.voters.length > 0
      return "Tänään #{this.voters}"
    else
      return ''
  winnerClass: () ->
    winner = getWinner()
    if winner && winner._id == this._id
      return 'winner'
    else
      return ''

Template.lunchList.events
  'click .upvote': (e) ->
    e.preventDefault()
    Meteor.call('vote', this._id)

@votersToday = ->
  lunches = Lunches.find {voted: true}
  votersToday = []
  votersToday.push.apply(votersToday, lunches.map (lunch) -> lunch.voters)
  return _.flatten(votersToday)

@getWinner = ->
  Lunches.find({voted: true}, {sort: {votes: -1, restaurantScore: -1}, limit: 1}).fetch()[0]
