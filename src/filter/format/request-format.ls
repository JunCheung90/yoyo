call-logs-neccessary = [
  {
    type: null
    phone-number: null
    duration: null
    time: null
  }
]

callLogs-allowed = [
  {
    phoneNumber: null 
    type: null
    duration: null
    time: null
  }
]

contacts-neccesary = [
  {
    cid: null
    cid-in-client: null
  }
]

ims-allowed = [
  {
    type: null
    account: null
    is-active: null
    api-key: null
  }
]

sns-allowed = [
  {
    type: null
    account-name: null
    account-id: null
    api-key: null
  }
]

request-format = 
  user-register:
    content-type: 'json'
    request-neccesary:
      user: 
        contacts: 
          [{cid-in-client: null}]
      call-logs: call-logs-neccessary
      last-call-log-time: null
    request-allowed: 
      user:
        name: null
        birthday: null
        phones:
          [
            {
              phone-number: null
              is-active: null
            }
          ]
        emails: [null]
        ims: ims-allowed
        sns: sns-allowed
        addresses: [null]
        tags: [null]
        contacts:
          [
            {
              cid-in-client: null
              names: [null]
              birthday: null
              phones: [null]
              emails: [null]
              ims: 
                [
                  {
                    type: null
                    account: null
                  }
                ]
              sns: 
                [
                  {
                    type: null
                    account-name: null
                    account-id: null
                  }
                ]
              tags: [null],
              addresses: [null]
            }
          ]
      call-logs: callLogs-allowed
      last-call-log-time: null


  user-update:
    content-type: 'json'
    request-neccesary:
      uid: null
    request-allowed: null


  contact-synchronize:
    content-type: 'json'
    request-neccesary:
      uid: null
      contacts: contacts-neccesary
    request-allowed: null


  call-log-synchronize:
    content-type: 'json'
    request-neccesary:
      uid: null
      call-logs: call-logs-neccessary
      last-call-log-time: null
    request-allowed: null


  sns-update:
    content-type: 'json'
    request-neccesary:
      uid: null
    request-allowed: null
      

  contact-sns-update:
    content-type: 'json'
    request-neccesary:
      uid: null
      cid: null
      since-id-configs: null
    request-allowed: null
      

  sn-api-key-upload:
    content-type: 'json'
    request-neccesary:
      uid: null
      sn: 
        type: null
        account-name: null
        account-id: null
        api-key: null
    request-allowed: null
      
  interesting-infos:
    content-type: 'json'
    request-neccesary:
      uid: null
    request-allowed: null
    
  get-format-by-url: !(url)->
    if url.length <= 0
      return null
    if url.charAt 0 === '/' 
      return this[url.slice(1, url.length)]
    else
      return this[url]

module.exports <<< request-format