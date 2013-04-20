require! ['./interesting-info/interesting-info-mining','../db/database','sleep']


<-! database.init-mongo-client
(db) <-! database.get-db

while true
      sleep.sleep(5)
      console.log "start mining trun\n"
      (err,collection) <-! db.collection "users"
      (err,users) <-! collection.find {}

      for user in users
          if user.uid != null
             interesting-info-mining.mining-user-interesting-info user

      console.log "mining finished\n"

