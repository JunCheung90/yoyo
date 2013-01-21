require! 'node-uuid'

get-UUid = ->
	node-uuid.v1!

(exports ? this) <<< {get-UUid}
