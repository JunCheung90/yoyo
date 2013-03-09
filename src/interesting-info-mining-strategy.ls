/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

interesting-info-mining-strategy = 
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