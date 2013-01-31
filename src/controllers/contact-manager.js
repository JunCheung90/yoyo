if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
var couch, getContactById, storeContacts, mergeContacts, updateContactDoc, ref$;
couch = require('../servers-init').couch;
getContactById = function(contactId, callback){
  couch.get('/test_db/my_contacts', function(err, req, res, data){
    var i$, ref$, len$, i, contact, result;
    if (err) {
      throw new Error(err);
    }
    for (i$ = 0, len$ = (ref$ = data.Contacts).length; i$ < len$; ++i$) {
      i = i$;
      contact = ref$[i$];
      if (contact.id === contactId) {
        result = contact;
      }
    }
    callback(contact);
  });
};
storeContacts = function(contacts, callback){
  console.log(arguments.callee.name + " is NOT IMPLEMENTED YET!");
  callback();
};
mergeContacts = function(contacts, callback){
  console.log(arguments.callee.name + " is NOT IMPLEMENTED YET!");
  callback();
};
updateContactDoc = function(contacts, callback){
  console.log(arguments.callee.name + " is NOT IMPLEMENTED YET!");
  callback();
};
ref$ = typeof exports != 'undefined' && exports !== null ? exports : this;
ref$.getContactById = getContactById;
ref$.storeContacts = storeContacts;
ref$.mergeContacts = mergeContacts;
ref$.updateContactDoc = updateContactDoc;