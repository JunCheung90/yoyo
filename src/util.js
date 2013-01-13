var getUUid;
getUUid = function(){
  return new Date().getTime() + Math.random();
};
(typeof exports != 'undefined' && exports !== null ? exports : this).getUUid = getUUid;