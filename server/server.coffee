fs = Npm.require('fs')
meteor_root = process.env.PWD

dateStamp = ->
 date = new Date()
 year = date.getFullYear()
 month = (1 + date.getMonth()).toString()
 month = month.length > 1 ? month : '0' + month
 day = date.getDate().toString()
 day = day.length > 1 ? day : '0' + day
 return year + '' + month + '' + day


Meteor.methods
  getFiles: () ->
    console.log 'getFiles'
    files = fs.readdirSync(meteor_root + '/public/images')
    files.forEach (file) ->
      return if !file.match(/\d{8}_.+\.png/)
      return if Lunches.findOne {image: file}

      date = file.match(/\d{8}/)[0]
      restaurantName = file.replace(date+'_','').replace(/_/g, ' ').split('.')[0] 
      restaurant = Restaurants.findOne {name: restaurantName}

      if restaurant
        restaurantId = restaurant._id
      else
        console.log 'inserting: ' + restaurantName
        restaurantId = Restaurants.insert {name: restaurantName, votes: 0}
        restaurant = Restaurants.findOne restaurantId

      Lunches.insert
        image: file
        voters: []
        date: new Date()
        voted: false
        votes: 0
        restaurantId: restaurantId
        restaurantName: restaurantName
        restaurantVotes: restaurant.votes

  vote: (lunchId) ->
    user = Meteor.user()
    if !user
      throw new Meteor.Error(401, "You need to login to upvote")

    lunch = Lunches.findOne(lunchId)
    if !lunch
      throw new Meteor.Error(422, "Lunch not found")

    console.log lunch.votes

    lunch.$update
      $set:
        voted: true
        votes: lunch.votes + 1
      $addToSet:
        voters: user.username

    console.log lunch.votes

    restaurant = Restaurants.findOne lunch.restaurantId
    if restaurant
      restaurant.$set {votes: restaurant.votes + 1}


cron = new Meteor.Cron
  events:
    '* * * * *': =>
      Meteor.call 'getFiles'

