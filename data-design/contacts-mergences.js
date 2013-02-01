var contactsMergences, fs;
contactsMergences = {
  owner: "uid",
  mergences: [{
    from: 'cid-1',
    to: 'cid-2',
    isDirectMergence: false,
    startTime: 'timestamp of this mergence start',
    endTime: 'timestamp of this mergence end',
    isUserAccepted: false
  }]
};
fs = require('fs');
fs.writeFile('contacts-mergences.json', JSON.stringify(user, null, '\t'), function(err){
  if (err) {
    throw new Error(err);
  }
  console.log("user data have been exported to contacts-mergences.json");
});