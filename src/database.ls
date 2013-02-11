database =
  db: null
  client: null

  get-db: ->
    throw new Error "db isn't initialized" if !@db
    @db

module.exports = database