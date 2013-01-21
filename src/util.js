var nodeUuid, getUUid;
nodeUuid = require('node-uuid');
getUUid = function(){
  return nodeUuid.v1();
};
(typeof exports != 'undefined' && exports !== null ? exports : this).getUUid = getUUid;