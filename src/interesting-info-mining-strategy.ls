/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

interesting-info-mining-strategy = 
  never-contact:
    'roles': ['fromUid', 'toUid']
    'fields': []
    'time-quantum': 'TOTAL'
    'type': 'never-contact'
  call-out:
    'roles': ['fromUid']
    'fields': ['count']
    'time-quantum': 'MONTH'
    'type': 'most-call-out'
    'checker': 
  call-in:
    'roles': ['toUid']
    'fields': ['count']
    'time-quantum': 'MONTH'
    'type': 'most-call-in'
  most-contact:
    'roles': ['fromUid', 'toUid']
    'fields': ['count']
    'time-quantum': 'MONTH'
    'type': 'most-contact'
  call-out-miss:
    'roles': ['fromUid']
    'fields': ['missCount']
    'time-quantum': 'MONTH'
    'type': 'most-call-out-miss'
  call-in-miss:
    'roles': ['toUid']
    'fields': ['missCount']
    'time-quantum': 'MONTH'
    'type': 'most-call-in-miss'
  call-out-time:
    'roles': ['fromUid']
    'fields': ['duration']
    'time-quantum': 'MONTH'
    'type': 'most-call-out-time'
  call-in-time:
    'roles': ['toUid']
    'fields': ['duration']
    'time-quantum': 'MONTH'
    'type': 'most-call-in-time'



  cost-most: (user) ->
    {
      condition:
        filter: 
          type: 'MONTH'
          from-uid: user.uid
        sort-by: 'duration'
        order: 'desc'
        limit: 1
      interesting-info: '这个月以来，XXX花费你最多话费'
    }

module.exports <<< interesting-info-mining-strategy