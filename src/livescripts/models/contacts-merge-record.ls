require! ['../servers-init'.orm, 
					'../servers-init'.S,
					'./contact']

ContactsMergeRecord = orm.define 'ContactsMergeRecord', 
	reason: S.STRING
	effectiveTime: S.DATE
	state: S.STRING # MERGED | PENDING | REJECTED
	* 
		classMethods: {}
		instanceMethods: {}

ContactsMergeRecord.hasMany Contact, {as:'toBeMergedContacts'}

(exports ? this) <<< {ContactsMergeRecord}