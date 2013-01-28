/*
 * Created by Wang, Qing. All rights reserved.
 */

require! ['should', 'async', 'mongodb'.MongoClient, 'mongodb'.Server,
					'../../src/servers-init'.init-mongo-client, 
					'../../src/servers-init'.shutdown-mongo-client]

[db, client] = [null null]

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe 'MongoDB 用法', !->
	do
		(done) <-! before
		(mongo-client, mongo-db) <-! init-mongo-client
		[db, client] := [mongo-db, mongo-client]
		done!

	can '创建User张三', !(done) ->
		check-create-user-with 'zhangsan.json', '张三', done


	do
		(done) <-! after
		<-! shutdown-mongo-client client
		done!

!function check-create-user-with json-file-name, user-name, callback
	user-data = require "../test-data/#{json-file-name}"
	db.collection('users').insert user-data, (err, result)->
		should.not.exist err 
		callback!