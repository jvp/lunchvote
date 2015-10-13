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
  readFiles: () ->
    files = fs.readdirSync(meteor_root + '/images~/')
    files.forEach (file) ->
      return if !file.match(/\.txt$/)
      return if !file.match(dateStamp())

      content = fs.readFileSync(meteor_root + '/images~/' + file, 'utf-8')
      lunches = JSON.parse(content)

      restaurants = _.keys(lunches)
      restaurants.map (restaurant) ->
        restaurantName = restaurant
        console.log restaurantName
        lunchItems = lunches[restaurant]
        restaurant = Restaurants.findOne {name: restaurantName}

        if restaurant
          restaurantId = restaurant._id
        else
          console.log 'inserting: ' + restaurantName
          restaurantId = Restaurants.insert {name: restaurantName, votes: 0, score: 0, lastVote: null}
          restaurant = Restaurants.findOne restaurantId
        
        Lunches.upsert
            restaurantId: restaurantId
          ,
            $set:
              voters: []
              stars: []
              date: new Date()
              voted: false
              votes: 0
              restaurantId: restaurantId
              restaurantName: restaurantName
              restaurantVotes: restaurant.votes
              restaurantScore: restaurant.score
              lunchItems: lunchItems
     
  removeFiles: () ->
    files = fs.readdirSync(meteor_root + '/images~/')
    files.forEach (file) ->
      return if !file.match(/\d{8}_.+\.txt/)
      console.log 'removing: ' + file
      command = spawn('rm', [meteor_root + '/images~/' + file])
      command.stdout.on 'data', (data) ->
        #console.log('stdout: ' + data);
      command.stderr.on 'data', (data) ->
        throw new Error('stderr')
      command.on 'exit', (data) ->
        return 'exit'

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
        firstVote: if lunch.firstVote then lunch.firstVote else new Date()
      $addToSet:
        voters: user.username

    restaurant = Restaurants.findOne lunch.restaurantId
    if restaurant
      restaurant.$set
        votes: restaurant.votes + 1
        lastVote: new Date()

  getFiles: ->
    allAddresses = ''
    Addresses.find().fetch().forEach (address) ->
      allAddresses = allAddresses + address.url + ','

    command = spawn(phantomjs.path, [meteor_root + '/private/scraper.js', allAddresses, meteor_root + '/images~/' ])
    command.stdout.on 'data', (data) ->
      console.log('stdout: ' + data);
    command.stderr.on 'data', (data) ->
      throw new Error('stderr')
    command.on 'exit', (data) ->
      return 'exit'
    return true

  removeLunches: ->
    today = new Date()
    today.setHours(0,0,0,0)
    images = Lunches.remove {date: {$lte: today}}

cron = new Meteor.Cron
  events:
    '0 1 * * *': () ->
      console.log 'udpating scores'
      Meteor.call 'updateScores'
    '0 7 * * *': () ->
      console.log 'getFiles'
      Meteor.call 'getFiles'
    '10 7 * * *': () ->
      console.log 'readFiles'
      Meteor.call 'readFiles'
    '5 0 * * *': () ->
      console.log 'removeFiles'
      Meteor.call 'removeFiles'
    '15 0 * * *': () ->
      console.log 'removeLunches'
      Meteor.call 'removeLunches'

Meteor.methods
  'lastVote': (restaurantId) ->
    restaurant = Restaurants.findOne {_id: restaurantId }
    if restaurant == undefined
      return

    if restaurant.lastVote == null || restaurant.lastVote == undefined
      return

    lastVoteTime = moment(restaurant.lastVote)
    now = moment(new Date())
    now.diff(lastVoteTime, 'days')

  'calculateScore': (restaurantId) ->
    restaurant = Restaurants.findOne(restaurantId)
    if !restaurant
      return

    # Score = (P-1) / (T+2)^G
    votes = restaurant.votes
    daysFromLastVote = Meteor.call('lastVote', restaurantId)

    if daysFromLastVote == undefined
      return votes * 0.0001

    votes / Math.pow((daysFromLastVote+2), 1.8)

  'updateScores': () ->
    restaurants = Restaurants.find()
    restaurants.map (restaurant) ->
      score = Meteor.call('calculateScore', restaurant._id)
      console.log 'updating ' + restaurant.name + " -- " + score
      restaurant.$update
        $set:
          score: score


@dateStamp = () ->
  date = new Date()
  formattedDate = moment(date).format('YYYYMMDD')
  return formattedDate
