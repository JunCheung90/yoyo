/*
 * Created by Wang, Qing. All rights reserved.
 */

require! [fs, express, formidable, fs, util
  './controllers/contact-manager', 
  './controllers/user-manager',
  './controllers/sn-update-manager',
  './controllers/call-log-manager']

yoyo = express!
yoyo.use express.body-parser!

# 注册用户
do
  (req, res) <-! yoyo.post '/userRegister'
  necessary-params = ['user', 'callLogs', 'lastCallLogTime']
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code?
    (result) <-! user-manager.register-user req.body
    res.send result
  else
    res.send result

# 更新用户profile
do
  (req, res) <-! yoyo.post '/userUpdate'
  necessary-params = ['uid']
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code?
    (result) <-! user-manager.update-user req.body
    res.send result
  else
    res.send result

# 同步联系人
do
  (req, res) <-! yoyo.post '/contactSynchronize'
  necessary-params = ['uid', 'contacts']
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code?
    (result) <-! contact-manager.synchronize-user-contacts req.body
    res.send result
  else
    res.send result

# 同步通话记录
do
  (req, res) <-! yoyo.post '/callLogSynchronize'
  necessary-params = ['uid', 'callLogs', 'lastCallLogTime']
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code
    (result) <-! call-log-manager.synchronize-user-call-logs req.body
    res.send result
  else
    res.send result

# 获取社交更新
do
  (req, res) <-! yoyo.post '/snUpdate'
  necessary-params = ['uid']
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code?
    (result) <-! user-manager. req.body
    res.send result
  else
    res.send result

# 上传社交网络token
do
  (req, result) <-! yoyo.post './snApiKeyUpload'
  necessary-params = ['sn']
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code?
    (result) <-! user-manager.update-user-sn-api-key req.body
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

# 上传头像
do
  (req, res) <-! yoyo.post '/avatarUpload'
  uid = req.body.uid
  cid = req.body.cid
  source-path = req.files.img.path
  file-name = cid ? cid : uid 
  dest-path = "./avatars/#{uid}/"
  (exists) <-! fs.exists dest-path
  if !exists
    (err) <-! fs.mkdir dest-path
    throw new Error err if err
    <-! copy-avatar-to-dest file-name, source-path, dest-path    
    res.send 'hello'
  else
    <-! copy-avatar-to-dest file-name, source-path, dest-path
    res.send 'hello'

detected-json-data-integrity = (req, necessary-params) ->
  result = {}
  if req.headers.'content-time-quantum'.index-of("json") < 0  
    [result.result-code, result.error-message] = [1, 'request data is not json']
  else
    for param in necessary-params
      if !req.body[param]
        [result.result-code, result.error-message] = [2, "missing necessary param: #param"]
        break
  result

copy-avatar-to-dest = !(file-name, source-path, dest-path, callback) ->
  in-stream = fs.create-read-stream source-path
  out-stream = fs.create-write-stream dest-path + file-name + '.png'

  <-! util.pump in-stream, out-stream
  <-! fs.unlink source-path
  callback!


yoyo.listen 8888 
console.log 'yoyo is listening on port 8888'

