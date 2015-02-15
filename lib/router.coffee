Router.configure
  layoutTemplate: 'layout'
  waitOn : ->
    [
      Meteor.subscribe 'lunches'
      Meteor.subscribe 'restaurants'
      Meteor.subscribe 'addresses'
      Meteor.subscribe 'images'
    ]

Router.map ->
  @route 'lunchList', path: '/'
  @route 'addressList', path: '/urls'
