Template.charts.rendered = ->
  restaurants = Restaurants.find({votes: {$gt: 0}}).fetch()
  labels = (restaurant.name for restaurant in restaurants)
  series = (restaurant.votes for restaurant in restaurants)

  data =
    labels: labels,
    series: series

  new Chartist.Pie '.ct-chart', data, { width: '400px', height: '400px', donut: true }

