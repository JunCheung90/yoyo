require! '../../config/config'



Validator =
  has-valid-phones: (phones)->
    has-valid-items phones, @is-valid-phone

  has-valid-emails: (emails)->
    has-valid-items emails, @is-valid-email

  has-valid-ims: (ims)->
    has-valid-items ims, @is-valid-im

  has-valid-sns: (sns)->
    has-valid-items sns, @is-valid-sn

  #正则表达式引用url: http://www.cnblogs.com/flyker/archive/2009/02/12/1389435.html
  is-valid-phone: (phone)-> 
    '''
    匹配格式：
      11位手机号码
      3-4位区号，7-8位直播号码，1－4位分机号
      如：12345678901、1234-12345678-1234
    '''
    phone-reg-exp = /((\d{11})|^((\d{7,8})|(\d{4}|\d{3})-(\d{7,8})|(\d{4}|\d{3})-(\d{7,8})-(\d{4}|\d{3}|\d{2}|\d{1})|(\d{7,8})-(\d{4}|\d{3}|\d{2}|\d{1}))$)/
    phone-reg-exp.test phone #TODO：进一步完善

  is-valid-email: (email)->
    /.+@.+\..+/.test email #TODO：进一步完善

  is-valid-im: (im)->
    is-valid-provider im, config.communication-channels-validation.im.type-white-list

  is-valid-sn: (sn)->
    is-valid-provider sn, config.communication-channels-validation.sn.type-white-list

is-valid-provider = (channel, type-white-list) ->
  if channel?.type and channel?.account
    channel.type in type-white-list
  else
    false

has-valid-items = (items, validator)->
  if items?.length
    for item in items
      return true if validator item
  false

module.exports <<< Validator