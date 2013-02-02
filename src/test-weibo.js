var Weibo = require('../weibo').Weibo;
var User = require('../weibo').User;
var connect  = require('connect');

var app = new Weibo({
  app_key:  '2437764734',
  app_secret:  '468c0f5482ab4f8bf16cff51522207d4'
});
// app.listen(80);

var user = new User({
  access_token: '2.00C5OL3DCybyeCdff214e680ICSURC',
  uid: '3076154802',
  screen_name: 'ucent_YoYo'	//昵称
}, app);

// 可以使用GET或POST来操作，直接根据 API 名称来调用
user.get('2/statuses/user_timeline', {screen_name: '李开复', count: 1}, function (err, data) {
  if (err)
    console.log(err);
  else
    console.log(data);
});

user.post('2/statuses/repost', {id: 123456, status:'转发微博'}, function (err, data) {
  // .....
});

// 也可以创建一个调用某API的函数（仅针对当前用户），并可设置默认参数
var friends_timeline = user.api('GET', 'statuses/friends timeline', {count: 100});
// 以后直接用 friends_timeline()即可
friends_timeline(function (err, data) {
  // ...
});
// 或者设置参数并调用
friends_timeline({max_id: 1234445664}, function (err, data) {
  // ...
});
