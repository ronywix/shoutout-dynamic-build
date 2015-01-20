'use strict';
var walk = require('fs-walk');
var path = require('path');
var fs = require('fs');

String.prototype.endsWith = function(suffix) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
};

walk.files('src/', function(basedir, filename, stat, next) {
    var filePath;
    var buffer;
    var replacedStr;
    console.log(filename);
    if(isJsFile(filename)){
      filePath = path.resolve(basedir, filename);
      buffer = fs.readFileSync(filePath, 'utf8');
      replacedStr = replaceKeys(buffer);
      fs.writeFile(filePath, replacedStr);
    }
    next();
}, function(err) {
    if (err) console.log(err);
});

function isJsFile(filename){
  return filename.endsWith('.js');
}
function replaceKeys(str){
  return str.replace(/\brequire\b/g, 'tipackRequire');
}