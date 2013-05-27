require! ['should', 'async',
          '../test-data/register-data',
          '../../bin/filter/format/request-format']
filter = require '../../bin/filter/filter'
_ = require 'underscore'
can = it
describe '测试请求/响应数据过滤中间件', !->
  describe '测试content-type检测', !->
    can '正确的content-type' !(done) ->
      req = 
        headers:
          'content-type': 'application/json'
      result = filter.content-type-checker req, 'json'
      result.should.eql true
      done!

    can '错误的content-type' !(done) ->
      req = 
        headers:
          'content-type': 'text/html'
      result = filter.content-type-checker req, 'json'
      result.should.eql false
      done!

  describe '测试请求必须参数检测', !->
    can '不缺少必要参数' !(done) ->
      input = {}
      input <<< register-data
      result = 
        result-code: 0
        error-message: ""
      filter.neccesity-checker input, request-format.user-register.request-neccesary, result
      result.result-code.should.eql 0
      result.error-message.should.eql ''
      done!

    can '缺少必要参数', !(done)->
      input = {}
      input <<< register-data
      user = input.user
      delete input.user
      input.should.not.have.property 'user'
      result = 
        result-code: 0
        error-message: ""
      filter.neccesity-checker input, request-format.user-register.request-neccesary, result
      result.result-code.should.eql 2
      input.user = user
      done!

    can '存在额外参数', !(done) ->
      input = {}
      input <<< register-data
      input.extra = 'extra'
      format = request-format.user-register.request-neccesary
      result = 
        result-code: 0
        error-message: ""

      filter.neccesity-checker input, format, result
      result.result-code.should.eql 0
      result.error-message.should.eql ''
      done!

    can '深层缺少必要参数', !(done) ->
      input = {}
      input <<< register-data
      delete input.user.contacts
      input.user.should.not.have.property 'contacts'
      result = 
        result-code: 0
        error-message: ""
      filter.neccesity-checker input, request-format.user-register.request-neccesary, result
      result.result-code.should.eql 2
      done!
    
    can '数组成员缺少必要参数', !(done)->
      input = {}
      input <<< register-data
      phone-number = input.call-logs[0].phone-number
      delete input.call-logs[0].phone-number
      input.user.should.not.have.property 'contacts'
      result = 
        result-code: 0
        error-message: ""
      filter.neccesity-checker input, request-format.user-register.request-neccesary, result
      result.result-code.should.eql 2
      input.call-logs[0].phone-number = phone-number
      done!

  describe '测试响应无用数据过滤', !->
    can '没有多余数据', !(done) ->
      input = {}
      input <<< register-data
      format = request-format.user-register.request-allowed
      result = filter.redundancy-remover input, format
      result.should.eql input
      done!

    can '第一层多余数据', !(done) ->
      input = {}
      input <<< register-data
      input.extra = 132
      format = request-format.user-register.request-allowed
      result = filter.redundancy-remover input, format
      result.should.not.have.property 'extra'
      done!

    can '深层多余数据', !(done) ->
      input = {}
      input <<< register-data
      input.user.extra = 132
      format = request-format.user-register.request-allowed
      result = filter.redundancy-remover input, format
      result.user.should.not.have.property 'extra'
      done!

    can '多层多余数据', !(done) ->
      input = {}
      input <<< register-data
      input.extra = 'asdfczv'
      input.user.extra2 = 'asdfwera'
      input.user.extra1 = 
        name: 'zhangsan'
      format = request-format.user-register.request-allowed
      result = filter.redundancy-remover input, format
      result.should.not.have.property 'extra'
      result.user.should.not.have.property 'extra2'
      result.user.should.not.have.property 'extra'
      done!

    can '数组成员多余数据', !(done) ->
      input = {}
      input <<< register-data
      input.user.sns[0].extra = 
        extra: 132
      format = request-format.user-register.request-allowed
      result = filter.redundancy-remover input, format
      result.user.sns[0].should.not.have.property 'extra'
      done!