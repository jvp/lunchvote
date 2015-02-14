Router.configure
  layoutTemplate: 'layout'
  waitOn : ->
    [
      Meteor.subscribe 'lunches'
      Meteor.subscribe 'restaurants'
    ]

Router.map ->
  @route 'lunchList', path: '/'
