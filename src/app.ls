/*
 * Created by Wang, Qing. All rights reserved.
 */

require! [fs, express, util
  './manager/contact-manager', 
  './manager/user-manager',
  './manager/sn-update-manager',
  './manager/call-log-manager',
  './db/query-helper']

yoyo = express!
yoyo.use express.body-parser!

# 注册用户
do
  (req, res) <-! yoyo.post '/userRegister'
  necessary-params = ['user', 'callLogs', 'lastCallLogTime']
  necessary-return-properties =
    result-code: null
    error-message: null
    user: 
      uid: null
      cidInClient: null
      cid: null
      names: null
      phones: null
      birthday: null
      emails: null
      ims: null
      sns: null
      tags: null
      mergedTo: null
      mergedFrom: null
      pendingMerges: null

  result = detected-json-data-integrity req, necessary-params
  if !result.result-code?
    (result) <-! user-manager.register-user req.body
    result = clean-json result, necessary-return-properties
    res.send result
  else
    res.send result

# 更新用户profile
do
  (req, res) <-! yoyo.post '/userUpdate'
  necessary-params = ['uid']
  necessary-return-properties =
    result-code: null
    error-message: null
    user: 
      uid: null
      name: null
      gender: null
      contacts: null
      birthday: null
      phones: null
      emails: null
      ims: null
      sns: null
      addresses: null
      tags: null
      
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code?
    (result) <-! user-manager.update-user req.body
    result = clean-json result, necessary-return-properties
    res.send result
  else
    result = clean-json result, necessary-return-properties
    res.send result

# 同步联系人
do
  (req, res) <-! yoyo.post '/contactSynchronize'
  necessary-params = ['uid', 'contacts']
  necessary-return-properties =
    result-code: null
    error-message: null
    contacts: null
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code?
    (result) <-! contact-manager.synchronize-user-contacts req.body
    #result = clean-json result,necessary-return-properties
    res.send result
  else
    res.send result

# 同步通话记录
do
  (req, res) <-! yoyo.post '/callLogSynchronize'
  necessary-params = ['uid', 'callLogs', 'lastCallLogTime']
  necessary-return-properties =
    result-code: null
    error-message: null
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code
    (result) <-! call-log-manager.synchronize-user-call-logs req.body
    result = clean-json result, necessary-return-properties
    res.send result
  else
    res.send result

# 获取社交更新
do
  (req, res) <-! yoyo.post '/snUpdate'
  necessary-params = ['uid']
  necessary-return-properties =
    result-code: null
    error-message: null
    client-sn-update: 
      content: null
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code?
    (result) <-! user-manager. req.body
    clean-json result, necessary-return-properties
    res.send result
  else
    res.send result

# 上传社交网络token
do
  (req, result) <-! yoyo.post './snApiKeyUpload'
  necessary-params = ['sn']
  necessary-return-properties =
    result-code: null
    error-message: null
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code?
    (result) <-! user-manager.update-user-sn-api-key req.body
    result = clean-json result, necessary-return-properties
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

#获取有趣信息
do
  (req, res) <-! yoyo.post '/interestingInfos'
  necessary-params = ['uid']
  necessary-return-properties =
    result-code: null
    error-message: null
  result = detected-json-data-integrity req, necessary-params
  if !result.result-code
    uid = req.body.uid
    (users) <-! query-helper.get-users-by-uids [uid]
    if users.length > 0 and users[0].interesting-infos
      result.interesting-infos = users[0].interesting-infos
    else
      result.interesting-infos = []
    clean-json result, necessary-return-properties
    res.send result
  else
    result.interesting-infos = []
    clean-json result, necessary-return-properties
    res.send result
    
detected-json-data-integrity = (req, necessary-params) ->
  result = {}
  if req.headers.'content-type'.index-of("json") < 0  
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

#从util中复制来，util无法导入使用
function clean-json full-json, clean-format
  if clean-format == null || typeof clean-format != "object"
    return full-json 
  if (clean-format instanceof Array)
    copy = []
    for elem, i in clean-format
      copy[i] = clean-json full-json[i], clean-format[i]
    return copy  
  if (clean-format instanceof Object)
    copy = {}
    for key, val of clean-format
      if clean-format.hasOwnProperty(key) && full-json.hasOwnProperty(key)
        copy[key] = clean-json full-json[key], clean-format[key]
    return copy;  
  throw new Error "type isn't supported."  

yoyo.listen 8888 
console.log 'yoyo is listening on port 8888'

