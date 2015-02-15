Router.configure
  layoutTemplate: 'layout'
  waitOn : ->
    [
      Meteor.subscribe 'lunches'
      Meteor.subscribe 'restaurants'
      Meteor.subscribe 'addresses'
    ]

Router.map ->
  @route 'lunchList', path: '/'
  @route 'addressList', path: '/urls'
