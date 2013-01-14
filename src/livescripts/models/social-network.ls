require! ['../servers-init'.orm, '../servers-init'.S]

SocialNetwork = orm.define 'SocialNetwork', 
	account: S.STRING
	nickname: S.STRING
	appkey: S.STRING
	* 
		classMethods:
			create-social-network: !(social-data, callback) ->
	  		# TODO: Just for US1 in http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=111607873
				social = {account: social-data.AccountName, nickname: null, appkey: null}
				SocialNetwork.create social .success !(sn)->
					callback sn

		instanceMethods: {}

(exports ? this) <<< {SocialNetwork}	