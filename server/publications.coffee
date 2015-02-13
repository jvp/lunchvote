Meteor.publish 'lunches', ->
  today = new Date()
  today.setHours(0,0,0,0)
  #return Lunches.find {date: {$gte: today}}
  return Lunches.find {}

Meteor.publish 'restaurants', -> 
  return Restaurants.find {}
