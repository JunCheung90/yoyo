/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

interesting-info-mining-strategy = 
  strategys:
    * roles: ['fromUid', 'toUid']
      fields: []
      time-quantum: 'TOTAL'
      type: 'never-contact'
      checker: 'not-exist-node'
      rank-score: 0
    * roles: ['fromUid']
      fields: ['count']
      time-quantum: 'MONTH'
      type: 'most-call-out'
      checker: 'field-largest'
    * roles: ['toUid']
      fields: ['count']
      time-quantum: 'MONTH'
      type: 'most-call-in'
      checker: 'field-largest'
    * roles: ['fromUid', 'toUid']
      fields: ['count']
      time-quantum: 'MONTH'
      type: 'most-contact'
      checker: 'field-largest'
    * roles: ['fromUid']
      fields: ['missCount']
      time-quantum: 'MONTH'
      type: 'most-call-out-miss'
      checker: 'field-largest'
    * roles: ['toUid']
      fields: ['missCount']
      time-quantum: 'MONTH'
      type: 'most-call-in-miss'
      checker: 'field-largest'
    * roles: ['fromUid']
      fields: ['duration']
      time-quantum: 'MONTH'
      type: 'most-call-out-time'
      checker: 'field-largest'
    * roles: ['toUid']
      fields: ['duration']
      time-quantum: 'MONTH'
      type: 'most-call-in-time'
      checker: 'field-largest'



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