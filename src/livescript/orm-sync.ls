/*
 * Created by Wang, Qing. All rights reserved.
 */

require! ['./servers-init'.orm, './models/user', './models/phone']

drop-create-orm = !(callback) ->
	# orm.options.logging = console.log
	orm.sync {force: true} .success !->
		# console.log 'Success Sync ORM'
		orm.options.logging = false
		callback!

(exports ? this) <<< {drop-create-orm}	