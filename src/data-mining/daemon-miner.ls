II = require './interesting-info/interesting-info-mining'
RC = require './recommend-contact/recommend-contact'
require! ['../db/database','sleep']


<-! database.init-mongo-client
(db) <-! database.get-db

while true
      sleep.sleep(5)
      console.log "start mining trun"
      (err,collection) <-! db.collection "users"
      (err,users) <-! collection.find {}

      console.log "update interesting info"
      for user in users
          if user.uid != null
             II.mining-user-interesting-info user
      
      console.log "update recommend user info"
      for user in users
          if user.uid != null
             RC.update-user-recommend-info user

      console.log "mining finished"

