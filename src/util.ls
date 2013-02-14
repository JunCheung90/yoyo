/*
 * Created by Wang, Qing. All rights reserved.
 */

require! [fs, 'node-uuid', async, './database']
_ = require 'underscore'

util =
  event: new (require('events').EventEmitter)
  
  get-UUid: ->
    node-uuid.v4!

  load-json: (filename, encoding) ->
    try
      encoding ||= 'utf8'
      contents = fs.read-file-sync filename, encoding
      return JSON.parse contents
    catch err
      throw err

  to-camel-case: (str) ->
    str.replace /-([a-z])/g, (g) ->
      g[1].to-upper-case!
  
  create-map-on-attribute: (obj-array, attr)->
    map = {} 
    if _.is-array obj-array
      for obj in obj-array  
        continue if !obj[attr]
        map[obj[attr]] ||= []
        map[obj[attr]].push obj
    map

  is-early: (t-str1, t-str2) ->
    t1 = new Date t-str1
    t2 = new Date t-str2
    throw new Error "Can't convert to time!" if !t1 or !t2

  is-late: (t-str1, t-str2) ->
    !is-early t-str1, t-str2

  insert-multiple-docs: !(collection, docs, callback) ->
    db = database.get-db!
    if docs?.length > 0 then
      (err, docs) <-! db[collection].insert docs
      throw new Error err if err
      callback!  
    else
      callback! 

  update-multiple-docs: !(collection, docs, callback) ->
    db = database.get-db!
    if docs?.length > 0 then
      (err) <-! async.for-each docs, !(doc, next) ->
        (err, docs) <-! db[collection].save doc
        throw new Error err if err
        next!
      throw new Error err if err
      callback!
    else
      callback! 

  union: (set-a, set-b) ->
    set-a = set-a or []
    set-b = set-b or []
    _.compact _.union set-a, set-b

module.exports = util