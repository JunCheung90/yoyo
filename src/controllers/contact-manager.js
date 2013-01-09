var couch = require('../servers-init').couch;

var getContactById = function(contactId, callback){
	couch.get('/test_db/my_contacts', 
		function(err, req, res, data){
			if(err) throw new Error(err);
			var contact = null;
			for(var i = 0; i <= data.Contacts.length; i++){
				if(data.Contacts[i].id == contactId) {
					contact = data.Contacts[i];
					break;
				}
			}
			callback(contact);
	});
}

var storeContacts = function(contacts, callback){
	console.log('storeContacts is NOT IMPLEMENTED');
	callback();
}

var mergeContacts = function(contacts, result, callback){
	console.log('mergeContacts is NOT IMPLEMENTED');
	callback();
}

var updateContactDoc = function(contacts, callback){
	console.log('updateContactDoc is NOT IMPLEMENTED');
	callback();
}

exports.getContactById = getContactById;
exports.storeContacts = storeContacts;
exports.mergeContacts = mergeContacts;
exports.updateContactDoc = updateContactDoc;