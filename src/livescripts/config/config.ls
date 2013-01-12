(exports ? this) <<< 
	mysql:
		host: \localhost
		user: \yoyo
		password: \yoyo
		database: \spike_yoyo
	couch:
		url: 'http://localhost:5984'
		version: \*
		db: \test_db
	sequelize:
		'test_sequelize' 
		'yoyo' 'yoyo' 
		logging: false