if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
/*
 * Created by Wang, Qing. All rights reserved.
 */
var fs, nodeUuid, getUUid, loadJson, ref$;
fs = require('fs');
nodeUuid = require('node-uuid');
getUUid = function(){
  return nodeUuid.v1();
};
loadJson = function(filename, encoding){
  var contents, err;
  try {
    encoding || (encoding = 'utf8');
    contents = fs.readFileSync(filename, encoding);
    return JSON.parse(contents);
  } catch (e$) {
    err = e$;
    throw err;
  }
};
ref$ = typeof exports != 'undefined' && exports !== null ? exports : this;
ref$.getUUid = getUUid;
ref$.loadJson = loadJson;