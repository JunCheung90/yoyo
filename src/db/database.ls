require! ['../config/config'.mongo, 'mongodb'.MongoClient, 'mongodb'.Server]

database =
  db: null
  client: null

  # get-db: ->
  #   throw new Error "db isn't initialized" if !@db
  #   @db

  get-db: !(callback) ->
    if !@db
      (self) <-! @init-mongo-client
      callback self.db
    else
      callback @db

  init-mongo-client: !(callback) -> #mongo-client, db are used to return
    self = this
    @client = new MongoClient new Server mongo.host, mongo.port
    (err, client) <-! @client.open
    self.db = self.client.db(mongo.db)
    self.db.users = self.db.collection 'users'
    self.db.sn-update = self.db.collection 'sn-update'
    self.db.call-logs = self.db.collection 'call-logs'
    self.db.call-log-statistic = self.db.collection 'call-log-statistic'

    callback self

  shutdown-mongo-client: !(callback) ->
    @client.close! if @client
    callback!

module.exports <<< database