var fs, express, contactManager, userManager, yoyo;
fs = require('fs');
express = require('express');
contactManager = require('./controllers/contact-manager');
userManager = require('./controllers/user-manager');
yoyo = express();
yoyo.use(express.bodyParser());
yoyo.post('/user', function(req, res){
  userManager.registerUser(req.body, function(result){
    res.send(result);
  });
});
yoyo.get('/contact/:contactId', function(req, res){
  contactManager.getContactById(req.params.contactId, function(contact){
    res.send(contact);
  });
});
yoyo.get('/contact/avatar/:contactId', function(req, res){
  fs.readFile(__dirname + '/avatars/doudou.png', function(err, data){
    if (err) {
      throw err;
    }
    res.writeHead(200, {
      'Content-Type': 'image/png'
    });
    res.end(data, 'binary');
  });
});
yoyo.listen(8888);
console.log('yoyo is listening on port 8888');