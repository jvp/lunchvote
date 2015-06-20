Meteor.publish 'lunches', ->
  today = new Date()
  today.setHours(0,0,0,0)
  return Lunches.find {date: {$gte: today}}

Meteor.publish 'restaurants', -> 
  return Restaurants.find {}

Meteor.publish 'addresses', -> 
  return Addresses.find {}

Meteor.publish 'images', -> 
  return Images.find {}
