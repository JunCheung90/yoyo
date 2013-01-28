/*
 * Created by Wang, Qing. All rights reserved.
 */

require! [fs, express, 
	'./controllers/contact-manager', 
	'./controllers/user-manager']

yoyo = express!
yoyo.use express.body-parser!

# 注册用户
do
	(req, res) <-! yoyo.post '/user'
	(result) <-! user-manager.register-user req.body
	res.send result

# 查询某个联系人情况。（实际中使用较少，可能在未来移除）
do
	(req, res) <-! yoyo.get '/contact/:contactId'
	(contact) <-! contact-manager.get-contact-by-id req.params.contact-id
	res.send contact

# TODO：avatar查询，目前是临时实现。
do
	(req, res) <-! yoyo.get '/contact/avatar/:contactId'
	(err, data) <-! fs.read-file __dirname + '/avatars/doudou.png'
	throw err if err
	res.write-head 200, {'Content-Type': 'image/png'}
	res.end data, 'binary'

yoyo.listen 8888
console.log 'yoyo is listening on port 8888'

