// sn基本操作
var http = require('http')
  , https = require('https')
  , url = require('url')
  , querystring = require('querystring')
  , path = require('path')
  , util = require('util')
  , events = require('events');
  
/**
 * 创建应用
 *
 * @param {object} options 选项
 */
var Sn = function (options) {
  this.init_options();
  if (options)
    for (var i in options)
      this.options[i] = options[i];
  var u = url.parse(this.options.api_base);
  this.options.api_host = u.host;
  this.options.api_pathname = u.pathname || '';
  this.options.api_port = u.port;
  this.options.callback_url_path = url.parse(this.options.callback_url).pathname;
}
util.inherits(Sn, events.EventEmitter);

/** 默认配置 */
Sn.prototype.init_options = function () {
  // 应用配置
  this.options = 
      { oauth_url:           '/oauth'                    // 本地获取授权url
      , callback_url:        'http://127.0.0.1/callback' // 回调地址
      , api_base:            'https://api.weibo.com'     // 新浪微博API地址
      , oauth2_authorize:    '/oauth2/authorize'         // 请求授权页面
      , oauth2_access_token: '/oauth2/access_token'      // 请求授权token
      }
}

/**
 * 请求API
 *
 * @param {string} method 请求方法GET|POST
 * @param {string} apiname API名称，如 user_timeline/ids
 * @param {object} params 参数
 * @param {function} callback 回调函数
 */
Sn.prototype.request = function (method, apiname, params, callback) {
  var options = this.options;
  
  // 组装http.request()需要的参数
  method = method.toUpperCase();
  var path_str = path.join(options.api_pathname, apiname);
  path_str = path_str.replace(/\\/g,'\/');  //windows下转换反斜杠为斜杠
  var opt= { hostname:    options.api_host || '127.0.0.1'
           , port:    options.api_port || 443
           , method:  method || 'GET'
           , path:    path_str
           , headers: {}
  }
  
  // 发送请求，如果为POST或PUT，则需要设置相应的headers
  if (method == 'POST' || method == 'PUT') {
    var data = querystring.stringify(params);
    opt.headers['content-length'] = data.length;
    opt.headers['content-type'] = 'application/x-www-form-urlencoded';
    this.sendRequest(opt, data, callback);
  }
  else {
    opt.path += '?' + querystring.stringify(params);
    this.sendRequest(opt, null, callback);
  }
}

/**
 * 发送请求
 *
 * @param {object} options 选项
 * @param {Buffer|string} data 需要发送的额外数据
 * @param {function} callback 回调函数
 */
Sn.prototype.sendRequest = function (options, data, callback) {
  var req = https.request(options, function (res) {
    var length = parseInt(res.headers['content-length']);
    var resdata = new Buffer(length);
    var datacur = 0;
    res.on('data', function (chunk) {
      if (chunk.length + datacur > resdata.length) {
        var newbuff = new Buffer(chunk.length + datacur);
        resdata.copy(newbuff, 0, 0);
        resdata = newbuff;
      }
      chunk.copy(resdata, datacur, 0);
      datacur += chunk.length; 
    });
    res.on('end', function () {
      var data = JSON.parse(resdata);
      if (data.error)
        callback(data);
      else
        callback(null, data);
    });
  });
  req.on('error', function (err) {
    console.log(err.stack);
    callback({error: err.stack});
  });
  
  req.end(data);
};


/**
 * 微博用户操作
 *
 * @param {object} oauth 授权信息
 * @param {Sn} server 微博实例
 */
var User = function (oauth, server) {
  this.oauth = oauth;
  this.server = server;
};

/**
 * GET调用API
 *
 * @param {string} apiname API名称
 * @param {object} params 参数
 * @param {function} callback 回调函数
 */
User.prototype.get = function (apiname, params, callback) {
  if (!this.oauth.access_token) {
    callback({error: "No access_token!"});
  }
  params.access_token = this.oauth.access_token;
  this.server.request('GET', apiname + '.json', params, callback);
};

/**
 * POST调用API
 *
 * @param {string} apiname API名称
 * @param {object} params 参数
 * @param {function} callback 回调函数
 */
User.prototype.post = function (apiname, params, callback) {
  if (!this.oauth.access_token) {
    callback({error: "No access_token!"});
  }
  params.access_token = this.oauth.access_token;
  this.server.request('POST', apiname + '.json', params, callback);
};

/**
 * 生成调用API接口
 *
 * @param {string} method 请求方法GET|POST
 * @param {string} apiname API名称
 * @param {object} params 预加的参数
 * @return {function}
 */
User.prototype.api = function (method, apiname, params) {
  var self = this;
  params = params || {};
  // 调用时传递两个参数
  // 如：   friends_timeline_ids({count: 50}, function (err, data) { ...});
  return function (_params, callback) {
    // 如果仅有一个参数时
    if (typeof _params == 'function') {
      callback = _params;
      _params = {};
      for (var i in params) {
         _params[i] = params[i];
      }
       
    }
    // 有两个参数
    else {
      var nparams = {};
      for (var i in params) {
        nparams[i] = params[i];
      }
      for (var i in _params) {
        nparams[i] = _params[i];
      }
      _params = nparams;
    }
    // console.log(_params);
    self[method.toLowerCase()](apiname, _params, callback);
  }
}

// 模块输出
exports.Sn = Sn;
exports.User = User;