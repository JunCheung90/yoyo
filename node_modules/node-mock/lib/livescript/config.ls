module.exports <<< 
	mongo:
		host: \localhost
		port: 27017
		db: \yoyo-mock

	# --- Mock生成联系人配置 --- #
	yoyo-contact:
		user-amount: 10
		contacts-amount-mean: 5
		contacts-amount-std: 1.0	#标准差，值越小数据越集中
		contacts-amount-min: 1	#正态随机出的最小值
		contacts-amount-max: 1000	#正态随机出的最小值

		contacts-repeat-rate-mean: 0.1 #重复率，应直接合并 	
		contacts-repeat-rate-std: 1.0 	
		contacts-repeat-rate-min: 0.0 	
		contacts-repeat-rate-max: 0.5 	
		
		contacts-similar-repeat-rate-mean: 0.2 #疑似重复率，应推荐合并
		contacts-similar-repeat-rate-std: 1.0
		contacts-similar-repeat-rate-min: 0.0
		contacts-similar-repeat-rate-max: 0.5
		
		contacts-has-ims: 0.05 #有im的联系人占总体的比重
		contacts-has-sns: 0.03 #有im的联系人占总体的比重
		contacts-has-addresses: 0.02 #有im的联系人占总体的比重

		rule: #0不重复，1重复，依次为name,phone,email,im,sn,address
			repeat:
				[0, 0, 1, 0, 0, 0]
				[0, 0, 0, 0, 1, 0]
				[0, 0, 1, 0, 1, 0]
			similar:
				[1, 1, 0, 0, 0, 0]
				[1, 0, 0, 1, 0, 0]
				[1, 1, 0, 1, 0, 0]
			diff:
				[0, 0, 0, 0, 0, 0]
				[1, 0, 0, 0, 0, 0]
				[1, 0, 0, 0, 0, 1]