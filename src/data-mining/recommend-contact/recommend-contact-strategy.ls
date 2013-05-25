

recommend-contact-strategy = 
  strategys:
    * roles: ['fromUid', 'toUid']
      fields: ['recommendScore']
      time-quantum: 'MONTH'
      type: 'recommend-users-by-recent-month'
      checker: 'recommend-users-by-recent-score'
    ...
    #* roles: ['fromUid', 'toUid']
    #  fields: ['recommendScore']
    #  time-quantum: 'YEAR'
    #  type: 'recommend-users-by-recent-year'
    #  checker: 'recommend-users-by-recent-score'
    #* roles: ['fromUid', 'toUid']
    #  fields: ['recommendScore']
    #  time-quantum: 'DAY'
    #  type: 'recommend-users-by-recent-day'
    #  checker: 'recommend-users-by-recent-score'

module.exports <<< recommend-contact-strategy
