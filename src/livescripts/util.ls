get-UUid = ->
	new Date!.get-time! + Math.random!

(exports ? this) <<< {get-UUid}
