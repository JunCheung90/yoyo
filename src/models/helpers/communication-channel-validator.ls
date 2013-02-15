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
    !!im #TODO：进一步完善

  is-valid-sn: (sn)->
    !!sn #TODO：进一步完善


has-valid-items = (items, validator)->
  if items?.length
    for item in items
      return true if validator item
  false

module.exports <<< Validator