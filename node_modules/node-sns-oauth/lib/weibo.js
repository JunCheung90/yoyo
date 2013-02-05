//新浪微博API V2 http://open.weibo.com/wiki/API%E6%96%87%E6%A1%A3_V2 
var Sn = require('./sn').Sn;
var User = require('./sn').User;

var app = new Sn({
  app_key:  '2437764734',
  app_secret:  '468c0f5482ab4f8bf16cff51522207d4'
});

var Weibo = function (options) {
	this.user = new User(options, app);
	//配置接口
	this.user_timeline = this.user.api('GET', '2/statuses/user_timeline');  //获取用户发布的微博
	this.friends_timeline = this.user.api('GET', '2/statuses/friends_timeline');  //获取当前登录用户及其所关注用户的最新微博
	this.show = this.user.api('GET', '2/users/show'); //获取用户信息
};

module.exports = Weibo;