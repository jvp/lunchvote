Template.lunchList.helpers
  lunches: () ->
    return Lunches.find {}, {sort: {votes: -1, restaurantScore: -1}}
  votedToday: () ->
    user = Meteor.user()
    if user && !_.include(votersToday(), user.username)
      return false
    else
      return true
  randomVote: () ->
    lunches = Lunches.find({voted: true}).fetch()
    lunches.length >= 2 ? true : false

Template.lunch.helpers
  searchStatus: () ->
    searchTerm = Session.get('searchText')
    if searchTerm == undefined || searchTerm == ''
      return ''
    if this.restaurantName.match(new RegExp(Session.get('searchText'), 'i'))
      return 'searchResult'
    else
      return ''
  votedToday: () ->
    user = Meteor.user()
    if user && !_.include(votersToday(), user.username)
      return false
    else
      return true
  voters_list: () ->
    if this.voters.length > 0
      return "Tänään #{this.voters}"
    else
      return ''

Template.lunchList.events
  'click .upvote': (e) ->
    e.preventDefault()
    Meteor.call('vote', this._id)

  'submit #restaurantSearch': (e) ->
    e.preventDefault()
    text = e.target.text.value
    Session.set("searchText", text)
    e.target.text.value = ''

 'click #random-vote': (e) ->
    e.preventDefault()
    Meteor.call('randomVote')

@votersToday = ->
  lunches = Lunches.find {voted: true}
  votersToday = []
  votersToday.push.apply(votersToday, lunches.map (lunch) -> lunch.voters)
  return _.flatten(votersToday)
