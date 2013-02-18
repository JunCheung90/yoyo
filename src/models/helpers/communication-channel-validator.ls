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

  is-valid-phone: (phone)->
    !!phone #TODO：进一步完善

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