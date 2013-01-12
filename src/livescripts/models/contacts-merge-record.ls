require! ['../servers-init'.orm, '../servers-init'.S]

ContactsMergeRecord = orm.define 'ContactsMergeRecord', 
	reason: S.STRING
	effectiveTime: S.DATE
	state: S.STRING # MERGED | PENDING | REJECTED
	* 
		classMethods: {}
		instanceMethods: {}

(exports ? this) <<< {ContactsMergeRecord}

require! ['./contact'.Contact]

ContactsMergeRecord.hasMany Contact, {as:'toBeMergedContacts'}
