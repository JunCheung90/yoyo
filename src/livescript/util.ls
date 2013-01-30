/*
 * Created by Wang, Qing. All rights reserved.
 */

require! ['fs', 'node-uuid']

util =
  get-UUid: ->
    node-uuid.v1!

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
    

module.exports = util