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
      * start: 1 # 0 to 23
        end: 2 # 1 to 24, larger than start
        statistic-in-hour:
          count: 12
          miss-count: 1
          duration: 1000
  
  child-node:
    * type: 'YEAR'  
      start-time: '2013-01-01 13:00:00'
      end-time: '2013-01-01 13:00:00'
      statistic:
        count: 15
        miss-count: 1
        duration: 1245
        distribution-in-hour:
          * start: 1 # 0 to 23
            end: 2 # 1 to 24, larger than start
            statistic-in-hour:
              count: 12
              miss-count: 1
              duration: 1000
      child-node:
        * type: 'MONTH'  
          start-time: '2013-01-01 13:00:00'
          end-time: '2013-01-01 13:00:00'
          statistic:
            count: 15
            miss-count: 1
            duration: 1245
            distribution-in-hour:
              * start: 1 # 0 to 23
                end: 2 # 1 to 24, larger than start
                statistic-in-hour:
                  count: 12
                  miss-count: 1
                  duration: 1000
          child-node: []
        ...
    ...