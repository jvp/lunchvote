Template.addressList.helpers
  addresses: () ->
    return Addresses.find {}
  loaded: () ->
    console.log Session.get(this._id + 'loading_state')
    return Session.get(this._id + 'loading_state')

Template.addressList.events
  'submit .new-address': (e) ->
     e.preventDefault()
     url = e.target.text.value
     Meteor.call 'addUrl', url
  'click .run': () ->
     Meteor.call 'runPhantom', this.url
  'click .delete': () ->
     Meteor.call 'removeUrl', this._id

