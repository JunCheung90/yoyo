var Weibo = require('./lib/weibo');

var weibo = new Weibo({
  access_token: '2.00C5OL3DCybyeCdff214e680ICSURC',
  uid: '3076154802',
  screen_name: 'ucent_YoYo'	//昵称
});


// 当前用户最新发布的微博
weibo.user_timeline({count: 1}, function (err, data) {
  if (err)
    console.log(err);
  else
    console.log(data);
});

// 无参数的调用
// weibo.user_timeline(function (err, data) {
//   if (err)
//     console.log(err);
//   else
//     console.log(data);
// });

