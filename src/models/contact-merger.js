if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
/*
 * Created by Wang, Qing. All rights reserved.
 */
var MergeStrategy, _, util, mergeContacts, checkAndMergeContacts, shouldContactsBeMerged, mergeTwoContacts, selectMergeTo;
MergeStrategy = require('../contacts-merging-strategy');
_ = require('underscore');
util = require('../util');
mergeContacts = function(contacts){
  var checkedContacts, i$, len$, contact, uid;
  checkedContacts = [];
  for (i$ = 0, len$ = contacts.length; i$ < len$; ++i$) {
    contact = contacts[i$];
    uid = util.getUUid();
    contact.actByUser = util.getUUid();
    checkAndMergeContacts(contact, checkedContacts);
    checkedContacts.push(contact);
  }
};
checkAndMergeContacts = function(checkingContact, checkedContacts){
  var i$, len$, contact;
  for (i$ = 0, len$ = checkedContacts.length; i$ < len$; ++i$) {
    contact = checkedContacts[i$];
    if (contact.mergedTo) {
      continue;
    }
    switch (shouldContactsBeMerged(contact, checkingContact)) {
    case "NONE":
      continue;
    case "PENDING":
      checkingContact.isMergePending = contact.isMergePending = true;
      break;
    case "MERGED":
      checkingContact.isMergePending = contact.isMergePending = false;
    }
    mergeTwoContacts(contact, checkingContact);
  }
};
shouldContactsBeMerged = function(c1, c2){
  var i$, ref$, len$, key;
  for (i$ = 0, len$ = (ref$ = MergeStrategy.directMerging).length; i$ < len$; ++i$) {
    key = ref$[i$];
    if (_.isArray(c1[key])) {
      if (!_.isEmpty(_.intersection(c1[key], c2[key]))) {
        return "MERGED";
      }
    } else {
      if (_.isEqual(c1[key], c2[key])) {
        return "MERGED";
      }
    }
  }
  for (i$ = 0, len$ = (ref$ = MergeStrategy.recommandMerging).length; i$ < len$; ++i$) {
    key = ref$[i$];
    if (_.isArray(c1[key])) {
      if (!_.isEmpty(_.intersection(c1[key], c2[key]))) {
        return "PENDING";
      }
    } else {
      if (_.isEqual(c1[key], c2[key])) {
        return "PENDING";
      }
    }
  }
  return "NONE";
};
mergeTwoContacts = function(c1, c2){
  var mTo, mFrom, i$, ref$, len$, key;
  mTo = selectMergeTo(c1, c2);
  mFrom = mTo.cid === c1.cid ? c2 : c1;
  mTo.mergedFrom || (mTo.mergedFrom = []);
  mTo.mergedFrom.push(mFrom.cid);
  mFrom.mergedTo = mTo.cid;
  mFrom.actByUser = mTo.actByUser;
  if (mTo.isMergePending) {
    return null;
  }
  for (i$ = 0, len$ = (ref$ = _.keys(c1)).length; i$ < len$; ++i$) {
    key = ref$[i$];
    if (key == 'cid' || key == 'isMergePending' || key == 'mergedTo' || key == 'mergedFrom') {
      continue;
    }
    if (_.isArray(c1[key])) {
      mTo[key] = _.union(mTo[key], mFrom[key]);
    } else {
      if (mTo[key] !== mFrom[key]) {
        throw new Error(mTo.names + " and " + mFrom.names + " contact merging CONFLICT for key: " + key + ", with different value: " + mTo[key] + ", " + mFrom[key]);
      }
    }
  }
  return mTo;
};
selectMergeTo = function(c1, c2){
  return c1;
};
(typeof exports != 'undefined' && exports !== null ? exports : this).mergeContacts = mergeContacts;