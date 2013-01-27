require! ['should', 'async', 
          '../../src/models/User',
          '../../src/servers-init'.init-mongo-client, 
          '../../src/servers-init'.shutdown-mongo-client,
          '../../src/util']

[db, client] = [null null]

MULTIPLE-TIMES = 1000

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe 'mongoDb版的注册用户', !->
  do
    (done) <-! before
    (mongo-client, mongo-db) <-! init-mongo-client
    [db, client] := [mongo-db, mongo-client]
    <-! db.drop-collection 'users'
    done! 

  can '创建User张三，张三有2个Contacts，作为0人的Contact。\n', !(done) ->
    <-! create-and-check-user 'zhangsan.json', '张三', MULTIPLE-TIMES
    check-user-contacts '张三', MULTIPLE-TIMES + 2, 0, done

  can '创建User李四，李四有2个Contacts，作为1人的Contact。\n', !(done) ->
    <-! create-and-check-user 'lisi.json', '李四', MULTIPLE-TIMES
    check-user-contacts '李四', MULTIPLE-TIMES + 2, 1, done


  can '创建User赵五，赵五有3个Contacts，作为2人的Contacts。\n', !(done) ->
    <-! create-and-check-user 'zhaowu.json', '赵五', MULTIPLE-TIMES
    check-user-contacts '赵五', MULTIPLE-TIMES + 3, 2, done

  do
    (done) <-! after 
    <-! shutdown-mongo-client client
    done!

!function create-and-check-user json-file-name, user-name, fake-contacts-amount, callback
  user-data = util.load-json __dirname + "/../test-data/#{json-file-name}"
  user-data = multiple-contacts-data user-data, fake-contacts-amount
  console.log "\n\n*************** #{user-name} has #{user-data.contacts.length} contacts. ************************\n\n"
  (user) <-! User.create-user-with-contacts db, user-data
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-users[0].name.should.eql user-name
  console.log "\n\t成功创建了User：#{found-users[0].name}"
  callback! 

function multiple-contacts-data user-data, contacts-amount
  for i from 1 to contacts-amount
    user-data.contacts.push generate-fake-contact!
  user-data

function generate-fake-contact
  fake-contact =
    "phones":
      * Math.random! * 100000
        ...

!function check-user-contacts user-name, amount-of-has-contacts, amount-of-as-contacts, callback
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-user = found-users[0]
  found-user.contacts.length.should.eql amount-of-has-contacts
  # console.log "\n\t找回的User：#{user-name}有#{found-user.contacts.length}个联系人：%j", [[name for name in contact.names] for  contact in found-user.contacts]

  found-user.as-contact-of.length.should.eql amount-of-as-contacts
  console.log "\n\t找回的User：#{user-name}作为#{found-user.as-contact-of.length}个联系人"

  console.log "\n\t找回的User：#{user-name}有#{found-user.sns.length}个SN：%j" [{sn.sn-name, sn.account-name} for sn in found-user.sns]

  callback!     

