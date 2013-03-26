/*
 * Created by Wang, Qing. All rights reserved.
 */

require! [restify, should, '../../bin/database']

yoyo-config =
  url: 'http://localhost:8888'
  version: '~1.0'

client = restify.createJsonClient yoyo-config

can = it
user = null

describe '测试YoYo REST API' !->
  do
    (done) <-! before
    (db) <-! database.get-db
    <-! db.drop-collection 'users'
    <-! db.drop-collection 'call-logs'
    <-! db.drop-collection 'call-log-statistic'
    done!

  # can '查询联系人：GET /contact/10879 应当返回200' !(done) ->
  #   do 
  #     (err, req, res, data) <-! client.get '/contact/10879'
  #     should.not.exist err
  #     res.statusCode.should.eql 200
  #     done!

  can '注册用户：POST /userRegister 应当返回200' !(done) ->
    post-data = require '../test-data/register-data.json'
    post-data.last-call-log-time = new Date!.get-time!
    do
      (err, req, res, data) <-! client.post '/userRegister', post-data
      should.not.exist err 
      res.statusCode.should.eql 200
      response =  eval '(' + res.body + ')'
      response.should.have.property 'resultCode'

      # 正常应答
      response.result-code.should.eql 0
      response.should.have.property 'user'
      response.user.should.have.property 'uid'
      user := response.user
      done!

  can '更新用户profile：POST /userUpdate 应当返还200' !(done) ->
    post-data = require '../test-data/update-profile-data.json'
    post-data.uid = user.uid
    do
      (err, req, res, data) <-! client.post '/userUpdate', post-data
      should.not.exist err
      res.statusCode.should.eql 200
      response =  eval '(' + res.body + ')'
      response.should.have.property 'resultCode'

      response.result-code.should.eql 0

      response.should.have.property 'user'
      response.user.should.have.property 'uid'
      response.user.uid.should.eql user.uid

      response.user.phones.length.should.eql 2
      user := response.user   

      done!

  can '同步联系人：POST /contactSynchronize 应当返还200' !(done) ->
    user.contacts[0].cid-in-client = -1
    new-contacts = require '../test-data/new-contacts.json'
    for new-contact in new-contacts
      user.contacts.push new-contact
    do
      (err, req, res, data) <-! client.post '/contactSynchronize', user
      should.not.exist err
      res.statusCode.should.eql 200
      response =  eval '(' + res.body + ')'
      response.should.have.property 'resultCode'

      response.result-code.should.eql 0

      response.should.have.property 'contacts'

      response.contacts.length.should.eql 5  

      done!

  can '同步通话记录：POST /callLogSynchronize 应当返还200' !(done) ->
    new-call-logs = require '../test-data/new-call-logs.json'
    synchronize-data = {uid: user.uid, call-logs: new-call-logs, last-call-log-time: new Date!.get-time!}
    do
      (err, req, res, data) <-! client.post '/callLogSynchronize', synchronize-data
      should.not.exist err
      res.statusCode.should.eql 200
      response =  eval '(' + res.body + ')'
      response.should.have.property 'resultCode'

      done!