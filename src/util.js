if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
/*
 * Created by Wang, Qing. All rights reserved.
 */
var fs, nodeUuid, util;
fs = require('fs');
nodeUuid = require('node-uuid');
util = {
  getUUid: function(){
    return nodeUuid.v1();
  },
  loadJson: function(filename, encoding){
    var contents, err;
    try {
      encoding || (encoding = 'utf8');
      contents = fs.readFileSync(filename, encoding);
      return JSON.parse(contents);
    } catch (e$) {
      err = e$;
      throw err;
    }
  },
  toCamelCase: function(str){
    return str.replace(/-([a-z])/g, function(g){
      return g[1].toUpperCase();
    });
  }
};
module.exports = util;