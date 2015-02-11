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
        console.log 'inserting restaurant: ' + restaurantName
        restaurantId = Restaurants.insert {name: restaurantName, votes: 0}
        restaurant = Restaurants.findOne restaurantId

      Lunches.insert {
        image: file,
        voters: [],
        date: new Date(),
        votes: 0,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        restaurantVotes: restaurant.votes
      }

cron = new Meteor.Cron
  events: { '*/30 * * * *': Meteor.call 'getFiles' }

