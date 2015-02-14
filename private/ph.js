var system = require('system');
var args = system.args;
var page = require('webpage').create();
var address = args[1];
var addresses = [address];
var dateStamp = function(){
  var date = new Date();
  var year = date.getFullYear();
  var month = (1 + date.getMonth()).toString();
  month = month.length > 1 ? month : '0' + month;
  var day = date.getDate().toString();
  day = day.length > 1 ? day : '0' + day;
  return year + '' + month + '' + day;
};

function handle_page(address){
  console.log(address);
  page.open(address, function (status) {
    if (status !== 'success') {
      console.log('Unable to access the network!');
    } else {
      var list = page.evaluate(function () { 
        return document.querySelectorAll('.isotope-item');
      });

      var list_length = list.length;

      for(var i = 0; i < list_length; i++) {
        res = page.evaluate(function (i) { 
          var elem = document.querySelectorAll('.isotope-item')[i];
          var clip = elem.getBoundingClientRect();
          var title = elem.innerText.split('\n')[0].replace(/ /g,"_");
          return {clip: clip, title: title};
        }, i);
        res.clip.top += 100;
        page.clipRect = res.clip;
        var title = res.title;
        if (title !== '_') {
          page.render('public/images/' + dateStamp() + "_" + title + '.png');
        }
      }
    }
  });
  setTimeout(next_page,20000);
}
function next_page(){
  var file = addresses.shift();
  if(!file){
    console.log("end");
    phantom.exit(0);
  }
  handle_page(file);
}
next_page();
