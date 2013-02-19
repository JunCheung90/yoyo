user-call-logs-statistic = 
  from-user: 'uid-of-zhangsan'
  to-user: 'uid-of-lisi'
  statistic:
    count: 15
    duration: 1245
  
  child-node:
    * type: 'YEAR'
      interval: 2012
      distribution-in-hour:
        * interval: 0 # 0-23
          statistic:
            count: 12
            duration:1000
      statistic:
        count: 15
        duration: 1245
      child-node:
        * type: 'MONTH'
          interval: 1 # 1 to 12
          distribution-in-hour:
            * interval: 0
              statistic:
                count: 12
                duration:1000
          statistic:
            count: 12
            duration: 1000

          child-node:
            * type: 'WEEK'
              interval: 1
              distribution-in-hour:
                * interval: 0
                  statistic:
                    count: 12
                    duration:1000              
              statistic:
                count: 12
                duration: 1000 
              child-node:
                * type: 'DAY'
                  interval: 1 # 1 to 31
                  distribution-in-hour:
                    * interval: 0
                      statistic:
                        count: 12
                        duration:1000     
                  statistic:
                    count: 12
                    duration: 1000                  
                  child-node:
                    * type: 'HOUR'
                      interval: 0 # 0 to 23
                      distribution-in-hour: []
                      statistic:
                        count: 12
                        duration: 1000
                      child-node: null
                    ...
                ...
            ...
        ...
    ... 