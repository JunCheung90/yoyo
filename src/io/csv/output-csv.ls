require! ['../../db/database', csv, async]

Date.prototype.format = (format)->
  o = 
    "M+" : this.getMonth()+1
    "d+" : this.getDate()
    "h+" : this.getHours()
    "m+" : this.getMinutes()
    "s+" : this.getSeconds()
    "q+" : Math.floor((this.getMonth()+3)/3)
    "S" : this.getMilliseconds()
  

  if(/(y+)/.test(format)) 
    format = format.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length)); 
  

  for k, v of o
    if(new RegExp("("+k+")").test(format))
      format = format.replace(RegExp.$1, v); 
    
   
  return format; 

get-contact-name-by-phone = (user, phone) ->
  for contact in user.contacts
    if phone in contact.phones
      return contact.names[0]
  ""




(db) <-! database.get-db!
(err, user) <-! db.users.find-one {
  uid: '1a470cf4-0e0b-421f-b4ba-eccb2be7ff34'
}
(err, call-logs) <-! db.call-logs.find!.to-array!
(err) <-! async.for-each call-logs[0].call-logs, !(call-log, next) ->
  call-log.time = new Date call-log.time .format("yyyy-MM-dd hh:mm:ss")
  call-log.uid = get-contact-name-by-phone user, call-log.phone-number
  next!
throw new Error err if err
csv().from(call-logs[0].call-logs)
.to('./call_logs.csv');


iis = user.interesting-infos
iis-format = []
(err) <-! async.for-each iis, !(ii, next) ->
  start-time = ii.data.time-frame.start-time
  end-time = ii.data.time-frame.end-time
  ii-format = 
    type: ii.type 
    name: ii.data.related-contact.name

  console.log ii-format.name

  if start-time 
    ii-format.start-time = new Date start-time .format("yyyy-MM-dd hh:mm:ss")
    ii-format.end-time = new Date end-time .format("yyyy-MM-dd hh:mm:ss")
  else
    ii-format.start-time = ""
    ii-format.end-time = ""

  if ii.data.calling-in-times != null || ii.data.calling-in-times != undefined
    ii-format.calling-in-times = ii.data.calling-in-times
    ii-format.calling-in-amount-time = ii.data.calling-in-amount-time
    ii-format.calling-in-miss-times = ii.data.calling-in-miss-times
  else
    ii-format.calling-in-times = ""
    ii-format.calling-in-amount-time = ""
    ii-format.calling-in-miss-times = ""

  if ii.data.calling-out-times != null || ii.data.calling-out-times != undefined
    ii-format.calling-out-times = ii.data.calling-out-times
    ii-format.calling-out-amount-time = ii.data.calling-out-amount-time
    ii-format.calling-out-miss-times = ii.data.calling-out-miss-times
  else
    ii-format.calling-out-times = ""
    ii-format.calling-out-amount-time = ""
    ii-format.calling-out-miss-times = ""


  iis-format.push ii-format
  next!
throw new Error err if err
csv().from(iis-format)
.to('./iis.csv');

