user-call-logs-statistic = 
  from-user: 'uid-of-zhangsan'
  to-user: 'uid-of-lisi'

  type: 'ROOT'  
  start-time: '2013-01-01 13:00:00'
  end-time: '2013-01-01 13:00:00'
  statistic:
    count: 15
    miss-count: 1
    duration: 1245
    distribution-in-hour:
      * hour: 0 # 0 to 23
        count: 12
        miss-count: 1
        duration: 1000