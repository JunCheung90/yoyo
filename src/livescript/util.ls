/*
 * Created by Wang, Qing. All rights reserved.
 */

require! ['fs', 'node-uuid']

get-UUid = ->
  node-uuid.v1!

load-json = (filename, encoding) ->
  try
    encoding ||= 'utf8'
    contents = fs.read-file-sync filename, encoding
    return JSON.parse contents
  catch err
    throw err
    

(exports ? this) <<< {get-UUid, load-json}
