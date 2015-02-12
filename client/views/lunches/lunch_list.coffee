Template.lunchList.helpers
  lunches: () ->
    return Lunches.find({}, {sort: {restaurantScore: -1}})

Template.lunchList.rendered = ->
  $container = $('#lunches')
  $container.imagesLoaded(
    -> $container.masonry { itemSelector: '.lunch', isAnimated: true }
  )
