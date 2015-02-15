Template.addressList.helpers
  addresses: () ->
    return Addresses.find {}

Template.addressList.events
  'submit .new-address': (e) ->
     e.preventDefault()
     url = e.target.text.value
     Meteor.call 'addUrl', url
  'click .run': () ->
    Meteor.call 'runPhantom', this.url
  'click .delete': () ->
    Meteor.call 'removeAddress', this._id

