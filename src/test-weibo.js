var Weibo = require('./models/weibo').Weibo;
var User = require('./models/weibo').User;

//目前未用到appkey
var app = new Weibo({
  app_key:  '2437764734',
  app_secret:  '468c0f5482ab4f8bf16cff51522207d4'
});

var user = new User({
  access_token: '2.00C5OL3DCybyeCdff214e680ICSURC',
  uid: '3076154802',
  screen_name: 'ucent_YoYo'	//昵称
}, app);

// 微博API V2, http://open.weibo.com/wiki/API%E6%96%87%E6%A1%A3_V2
var friends_timeline = user.api('GET', '2/statuses/friends_timeline');  //获取当前登录用户及其所关注用户的最新微博
var user_timeline = user.api('GET', '2/statuses/user_timeline');  //获取用户发布的微博
var user_show = user.api('GET', '2/users/show'); //获取用户信息

// 当前用户最新发布的微博
user_timeline({count: 1}, function (err, data) {
  if (err)
    console.log(err);
  else
    console.log(data);
});

// 无参数的调用
// user_timeline(function (err, data) {
//   if (err)
//     console.log(err);
//   else
//     console.log(data);
// });
