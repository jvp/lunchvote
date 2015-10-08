var system = require('system');
var fs = require('fs');
var args = system.args;
var path = args[2];
var address = args[1];
var addresses = address.split(',');

var dateStamp = function(){
  var date = new Date();
  var year = date.getFullYear();
  var month = (1 + date.getMonth()).toString();
  month = month.length > 1 ? month : '0' + month;
  var day = date.getDate().toString();
  day = day.length > 1 ? day : '0' + day;
  return year + '' + month + '' + day;
};

function handle_page(address, path, callback){
  var page = require('webpage').create();
  var fs = require('fs');

  page.open(address, function (status) {
    if (status !== 'success') {
      console.log('Unable to access the network!');
      return phantom.exit(1);
    }

    var lunches = page.evaluate(function () { 
      return document.querySelectorAll('.isotope-item');
    });

    var lunchList = [];
    for(var i = 0; i < lunches.length; i++) {
      console.log(i);
      lunch = page.evaluate(function (i) { 
        var lunch = {};
        var elem = document.querySelectorAll('.isotope-item')[i];
        var title = elem.innerText.split('\n')[0].replace(/ /g,"_");

        lunch[title] = [];
        var menuItems = elem.querySelectorAll('.menu-item');
        for(var j = 0; j < menuItems.length; ++j) {
          var lunchItem = menuItems[j];
          lunch[title].push(lunchItem.innerText);
        }
        return lunch;
      }, i);
      if (lunch['title'] === '_') {
        continue;
      }
      lunchList.push(lunch);
    }
    fs.write('../images~/' + dateStamp() + '.txt', JSON.stringify(lunchList), 'w');
    page.close();
    callback.apply();
  });
}

function process() {
  if (addresses.length > 0) {
    var address = addresses[0];
    addresses.splice(0, 1);
    console.log(address);
    if (address.length > 0) {
      handle_page(address, path, process);
    }
  } else {
    console.log('exit');
    return phantom.exit();
  }
}

process();
