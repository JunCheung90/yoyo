/*
 * Created by Jiejun Zhang. All rights reserved.
 */


update-user-call-log = !(db, user, call-logs, callback) ->
	<-! call-log-data-mining db, user, call-logs
	callback user

get-contact-interesting-info-with-user = (db, user, call) ->
	interesting-info


call-log-data-mining = !(db, user, callback) ->
	(err, statistic) <-! db.call-log-statistic.find-one({user.uid})
	throw new Error err if err
	statistic ?= init-statistic user
	contact-statistic = statistic.contact-statistic ? {}
	user.calllogs ||= []
	for calllog, i in user.calllogs	
		switch calllog.type
		case 'IN' then
			contact-statistic[calllog.phone-number]in-count ?= 0
			contact-statistic[calllog.phone-number].in-count += 1
		case 'OUT' then
			contact-statistic[calllog.phone-number]out-count ?= 0
			contact-statistic[calllog.phone-number]out-count += 1
		case 'MISS' then
			contact-statistic[calllog.phone-number]miss-count ?= 0
			contact-statistic[calllog.phone-number]miss-count += 1

	console.log contact-statistic
	callback user

init-statistic = (user) ->
	statistic = 
		uid: user.uid
		in-count: 0
		in-duration: 0
		out-count: 0
		out-duration: 0

(exports ? this) <<< {update-user-call-log, get-contact-interesting-info-with-user}