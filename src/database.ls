servers-init = require './servers-init'

database =
  db: null
  client: null

  get-db: ->
    throw new Error "db isn't initialized" if !@db
    @db

  get-or-init-db: !(callback) ->
    if !@db
      (mongo-client, mongo-db) <-! servers-init.init-mongo-client
      @client = mongo-client
      @db = mongo-db
      callback @db
    else
      callback @db

module.exports <<< database