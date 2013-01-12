require! [restify, should]

yoyo-config =
	url: 'http://localhost:8888'
	version: '~1.0'

client = restify.createJsonClient yoyo-config

can = it

describe '测试YoYo REST API' !->
	can '查询联系人：GET /contact/10879 应当返回200' !(done) ->
		do 
			(err, req, res, data) <-! client.get '/contact/10879'
			should.not.exist err
			res.statusCode.should.eql 200
			done!

	can '注册用户：POST /user 应当返回200' !(done) ->
		post-data = require './zhangsan.json'
		do
			(err, req, res, data) <-! client.post '/user', post-data
			should.not.exist err 
			res.statusCode.should.eql 200
			done!
