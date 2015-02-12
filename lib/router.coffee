Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  waitOn : ->
    [
      Meteor.subscribe 'lunches'
      Meteor.subscribe 'restaurants'
    ]

Router.map ->
  @route 'lunchList', path: '/'
