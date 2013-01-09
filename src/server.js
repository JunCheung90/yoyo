var fs = require('fs');
var express = require('express');
var contactManager = require('./controllers/contact-manager');
var userManager = require('./controllers/user-manager');

var yoyo = express();
yoyo.use(express.bodyParser());


// 注册用户
yoyo.post('/user', function(req, res){
	// console.log(req.body);
	userManager.registerUser(req.body, function(result){
		res.send(result);
	});
});


// 查询某个联系人情况。（实际中使用较少，可能在未来移除）
yoyo.get('/contact/:contactId', function(req, res){
	contactManager.getContactById(req.params.contactId, function(contact){
		res.send(contact);
	});
});

// TODO：avatar查询，目前是临时实现。
yoyo.get('/contact/avatar/:contactId', function(req, res){
	fs.readFile(__dirname + '/avatars/doudou.png', function(err, data){
		if (err) throw err;
		res.writeHead(200, {'Content-Type': 'image/png'});
		res.end(data, 'binary');
	});
});

yoyo.listen(8888);
console.log("yoyo is listening on port 8888");

