response-formats =
  user-register:
    result-code: null
    error-message: null
    user: 
      uid: null
      name: null
      gender: null
      addresses: null
      contacts: null
      names: null
      phones: null
      birthday: null
      emails: null
      ims: null
      sns: null
      tags: null

  user-update:
    result-code: null
    error-message: null
    user: 
      uid: null
      name: null
      gender: null
      birthday: null
      phones: null
      emails: null
      ims: null
      sns: null
      addresses: null
      tags: null

  contact-synchonize:
    result-code: null
    error-message: null
    contacts: null

  call-log-synchronize:
    result-code: null
    error-message: null

  sns-update:
    result-code: null
    error-message: null
    sns-updates: null

  contact-sns-update:
    result-code: null
    error-message: null
    contact-sns-updates: null

  sn-api-key-upload:
    result-code: null
    error-message: null

  interesting-infos:
    result-code: null
    error-message: null
    interesting-infos: null


module.exports <<< response-formats