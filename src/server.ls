/*
 * Created by Wang, Qing. All rights reserved.
 */

require! [fs, express, 
  './controllers/contact-manager', 
  './controllers/user-manager',
  './controllers/call-log-manager']

yoyo = express!
yoyo.use express.body-parser!

# 注册用户
do
  (req, res) <-! yoyo.post '/userRegister'  
  (result) <-! detected-is-json req
  if !result
    (result) <-! user-manager.register-user req.body
    res.send result
  else
    res.send result

# 更新用户profile
do
  (req, res) <-! yoyo.post '/userUpdate'
  (result) <-! detected-is-json req
  if !result
    (result) <-! user-manager.update-user req.body
    res.send result
  else
    res.send result

# 同步联系人
do
  (req, res) <-! yoyo.post '/contactSynchronize'
  (result) <-! detected-is-json req
  if !result
    (result) <-! contact-manager.synchronize-user-contacts req.body
    res.send result
  else
    res.send result

# 同步通话记录
do
  (req, res) <-! yoyo.post '/callLogSynchronize'
  (result) <-! detected-is-json req
  if !result
    (result) <-! call-log-manager.synchronize-user-call-logs req.body
    res.send result
  else
    res.send result

# 获取社交更新
do
  (req, res) <-! yoyo.post '/snUpdate'
  (result) <-! detected-is-json req
  if !result
    (result) <-! sn-manager.get-sn-update req.body
    res.send result
  else
    res.send result

# 查询某个联系人情况。（实际中使用较少，可能在未来移除）
do
  (req, res) <-! yoyo.get '/contact/:contactId'
  (contact) <-! contact-manager.get-contact-by-id req.params.contact-id
  res.send contact

# TODO：avatar查询，目前是临时实现。
do
  (req, res) <-! yoyo.get '/contact/avatar/:contactId'
  (err, data) <-! fs.read-file __dirname + '../resources/avatars/doudou.png'
  throw err if err
  res.write-head 200, {'Content-Type': 'image/png'}
  res.end data, 'binary'

detected-is-json = !(req, callback) ->
  if req.headers.'content-type' != "application/json"
    result = {}
    [result.result-code, result.error-message] = [1, 'request data is not json']
    callback result
  else
    callback null


yoyo.listen 8888 
console.log 'yoyo is listening on port 8888'

