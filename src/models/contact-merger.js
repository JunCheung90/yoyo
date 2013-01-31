if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
/*
 * Created by Wang, Qing. All rights reserved.
 */
var MergeStrategy, _, util, Checkers, mergeContacts, checkAndMergeContacts, shouldContactsBeMerged, directMergeContacts, pendingMergeContacts, updatePendings, mergeContactsInfo, selectDistination, combine;
MergeStrategy = require('../contacts-merging-strategy');
_ = require('underscore');
util = require('../util');
Checkers = require('./Checkers');
mergeContacts = function(contacts){
  var checkedContacts, i$, len$, contact;
  checkedContacts = [];
  for (i$ = 0, len$ = contacts.length; i$ < len$; ++i$) {
    contact = contacts[i$];
    checkAndMergeContacts(contact, checkedContacts);
    contact.actByUser || (contact.actByUser = util.getUUid());
    checkedContacts.push(contact);
  }
};
checkAndMergeContacts = function(checkingContact, checkedContacts){
  var i$, len$, contact, isMerging, distination, source;
  for (i$ = 0, len$ = checkedContacts.length; i$ < len$; ++i$) {
    contact = checkedContacts[i$];
    if (contact.mergedTo) {
      continue;
    }
    if (in$(contact.cid, (checkingContact != null ? checkingContact.notMergeWith : void 8) || [])) {
      continue;
    }
    isMerging = shouldContactsBeMerged(contact, checkingContact);
    if (isMerging === "NONE") {
      continue;
    }
    distination = selectDistination(contact, checkingContact);
    source = distination.cid === contact.cid ? checkingContact : contact;
    debugger;
    if (isMerging === "DIRECT") {
      directMergeContacts(source, distination);
    }
    if (isMerging === "PENDING") {
      pendingMergeContacts(source, distination);
    }
  }
};
shouldContactsBeMerged = function(c1, c2){
  var directMergeCheckingFields, pendingMergeCheckingFields, i$, len$, key, j$, ref$, len1$, checker;
  if (c1.mergedTo || c2.mergedTo) {
    return "NONE";
  }
  directMergeCheckingFields = _.keys(MergeStrategy.directMerging);
  pendingMergeCheckingFields = _.keys(MergeStrategy.recommandMerging);
  for (i$ = 0, len$ = directMergeCheckingFields.length; i$ < len$; ++i$) {
    key = directMergeCheckingFields[i$];
    for (j$ = 0, len1$ = (ref$ = MergeStrategy.directMerging[key]).length; j$ < len1$; ++j$) {
      checker = ref$[j$];
      checker = util.toCamelCase(checker);
      if (Checkers[checker](c1[key], c2[key])) {
        return "DIRECT";
      }
    }
  }
  for (i$ = 0, len$ = pendingMergeCheckingFields.length; i$ < len$; ++i$) {
    key = pendingMergeCheckingFields[i$];
    for (j$ = 0, len1$ = (ref$ = MergeStrategy.recommandMerging[key]).length; j$ < len1$; ++j$) {
      checker = ref$[j$];
      checker = util.toCamelCase(checker);
      if (Checkers[checker](c1[key], c2[key])) {
        return "PENDING";
      }
    }
  }
  return "NONE";
};
directMergeContacts = function(source, distination){
  distination.mergedFrom || (distination.mergedFrom = []);
  distination.mergedFrom.push(source.cid);
  source.mergedTo = distination.cid;
  distination.actByUser || (distination.actByUser = source.actByUser);
  mergeContactsInfo(source, distination);
  return updatePendings(source, distination);
};
pendingMergeContacts = function(source, distination){
  source.pendingMergences || (source.pendingMergences = []);
  source.pendingMergences.push = {
    'pending-merge-to': distination.cid
  };
  distination.pendingMergences || (distination.pendingMergences = []);
  distination.pendingMergences.push = {
    'pending-merge-from': source.cid
  };
  return distination;
};
updatePendings = function(source, distination){
  if (!source.pendingMergences) {
    return;
  }
  distination.pendingMergences || (distination.pendingMergences = []);
  distination.pendingMergences.concat(source.pendingMergences);
};
mergeContactsInfo = function(source, distination){
  var i$, ref$, len$, key;
  for (i$ = 0, len$ = (ref$ = _.keys(source)).length; i$ < len$; ++i$) {
    key = ref$[i$];
    if (key == 'cid' || key == 'mergedTo' || key == 'mergedFrom' || key == 'pendingMergences') {
      continue;
    }
    if (_.isArray(source[key])) {
      distination[key] = combine(source[key], distination[key]);
    } else {
      if (distination[key] !== source[key]) {
        throw new Error(distination.names + " and " + source.names + " contact merging CONFLICT for key: " + key + ", with different value: " + distination[key] + ", " + source[key]);
      }
    }
  }
  return distination;
};
selectDistination = function(c1, c2){
  return c1;
};
combine = function(source, distination){
  var ref$, i$, len$, s, j$, len1$, d, exist;
  if (source.length === 0 && distination.length === 0) {
    return;
  }
  if ((ref$ = source[0]) != null && ref$.type) {
    for (i$ = 0, len$ = source.length; i$ < len$; ++i$) {
      s = source[i$];
      for (j$ = 0, len1$ = distination.length; j$ < len1$; ++j$) {
        d = distination[j$];
        if (_.isEqual(s, d) && s) {
          exist = true;
          break;
        }
      }
      if (!exist) {
        distination.push(s);
      }
      exist = false;
    }
  } else {
    debugger;
    distination = _.union(distination, source);
  }
  return distination;
};
(typeof exports != 'undefined' && exports !== null ? exports : this).mergeContacts = mergeContacts;
function in$(x, arr){
  var i = -1, l = arr.length >>> 0;
  while (++i < l) if (x === arr[i] && i in arr) return true;
  return false;
}