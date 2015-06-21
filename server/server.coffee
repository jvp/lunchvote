fs = Npm.require('fs')
meteor_root = process.env.PWD
phantomjs = Meteor.npmRequire('phantomjs')
spawn = Meteor.npmRequire('child_process').spawn

Meteor.startup -> 
  if Addresses.find().count() == 0
    [
      'http://lounaat.info/satakunnankatu-22-tampere'
      'http://lounaat.info/satakunnansilta-tampere'
      'http://lounaat.info/veturiaukio-4-tampere'
    ].forEach (address) ->
      Addresses.insert {url: address}

Meteor.methods
  importImages: () ->
    files = fs.readdirSync(meteor_root + '/images~/')
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

      image = Images.insert meteor_root + '/images~/' + file
      if image
        console.log 'removing: ' + restaurantName
        command = spawn('rm', [meteor_root + '/images~/' + file])
        command.stdout.on 'data', (data) ->
          #console.log('stdout: ' + data);
        command.stderr.on 'data', (data) ->
          throw new Error('stderr')
        command.on 'exit', (data) ->
          return
      
      Lunches.insert
        image: file
        voters: []
        stars: []
        date: new Date()
        voted: false
        votes: 0
        imageId: image._id
        restaurantId: restaurantId
        restaurantName: restaurantName
        restaurantVotes: restaurant.votes
        firstVote: null

  removeFiles: () ->
    files = fs.readdirSync(meteor_root + '/images~/')
    files.forEach (file) ->
      console.log 'removing: ' + file
      command = spawn('rm', [meteor_root + '/images~/' + file])
      command.stdout.on 'data', (data) ->
        #console.log('stdout: ' + data);
      command.stderr.on 'data', (data) ->
        throw new Error('stderr')
      command.on 'exit', (data) ->
        return
      
  vote: (lunchId) ->
    user = Meteor.user()
    if !user
      throw new Meteor.Error(401, "You need to login to upvote")

    lunch = Lunches.findOne(lunchId)
    if !lunch
      throw new Meteor.Error(422, "Lunch not found")

    lunch.$update
      $set:
        voted: true
        votes: lunch.votes + 1
        restaurantVotes: lunch.restaurantVotes + 1
        firstVote: if lunch.firstVote then lunch.firstVote else new Date()
      $addToSet:
        voters: user.username

    restaurant = Restaurants.findOne lunch.restaurantId
    if restaurant
      restaurant.$set {votes: restaurant.votes + 1}

  getFiles: ->
    allAddresses = ''
    Addresses.find().fetch().forEach (address) ->
      allAddresses = allAddresses + address.url + ','

    command = spawn(phantomjs.path, [meteor_root + '/private/ph.js', allAddresses, meteor_root + '/images~/' ])
    command.stdout.on 'data', (data) ->
      #console.log('stdout: ' + data);
    command.stderr.on 'data', (data) ->
      throw new Error('stderr')
    command.on 'exit', (data) ->
      return

  removeImages: ->
    today = new Date()
    today.setHours(0,0,0,0)
    images = Images.remove {uploadedAt: {$lte: today}}

  removeLunches: ->
    today = new Date()
    today.setHours(0,0,0,0)
    images = Lunches.remove {date: {$lte: today}}

cron = new Meteor.Cron
  events:
    '0 7 * * *': () ->
      console.log 'getFiles'
      Meteor.call 'getFiles'
    '10 7 * * *': () ->
      console.log 'importImages'
      Meteor.call 'importImages'
    '5 0 * * *': () ->
      console.log 'removeFiles'
      Meteor.call 'removeFiles'
    '10 0 * * *': () ->
      console.log 'removeImages'
      Meteor.call 'removeImages'
    '15 0 * * *': () ->
      console.log 'removeLunches'
      Meteor.call 'removeLunches'




