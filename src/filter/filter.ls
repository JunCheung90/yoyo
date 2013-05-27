require! [util, './format/request-format', './format/response-format']

filter =
  content-type-checker: (req, content-type)->
    req.headers.'content-type'.index-of(content-type) >= 0
    #req.is content-type

  neccesity-checker: !(input, format, result)->

    re = neccesity-checker-recursion input, format, result
    if result.missing-params
      for i in result.missing-params
        result.error-message += (' ' + i)
      delete result.missing-params

  redundancy-remover: (input, format)->
    clean-json input, format

  filter-request: !(err, req, res, next)->
    req-format = request-format.get-format-by-url req.originalUrl
    result = 
      result-code: 0
      error-message: ""

    if !content-type-checker req, req-format.content-type
      [result.result-code, result.error-message] = [1, "Unsupported content type"]
      res.send result

    console.log req-format

    neccesity-checker req, req-format.request-neccesary, result

    console.log result
    if !result.result-code
      next ...
    else res.send result

neccesity-checker-recursion = (input, format, result)->
  log-missing-param = !(missing-param-name, result)->
      if !result.missing-params
        result.missing-params = []
      if !result.result-code
        [result.result-code, result.error-message] = [2, "missing necessary param: "]
      result.missing-params.push missing-param-name
  /*if format == null
    return input != undefined
  if typeof format != "object"
    if typeof! format == "String"
      return typeof input == format
    else if typeof! format == "RegEx"
      return typeof! input == "String" and input.match(format)
    else return true*/
  truth = true
  if format == null || typeof format != "object"
    return truth
  if format instanceof Array
    if input instanceof Array
      if format.length > 0
        for elem, i in input
          truth &&= neccesity-checker-recursion input[i], format[0], result
        return truth
      else
        return true
    else
      return false
  if format instanceof Object
    for key, val of format
      if format.hasOwnProperty(key) && input.hasOwnProperty(key)
        truth &&= neccesity-checker-recursion input[key], format[key], result
      else
        truth = false
        log-missing-param key, result
    return truth
  throw new Error "type isn't supported."

clean-json = !(full-json, format)->
  if format == null || typeof format != "object"
      return full-json 
  if format instanceof Array
    copy = []
    if full-json instanceof Array 
      if format.length > 0
        for elem, i in full-json
          copy[i] = clean-json full-json[i], format[0]
        return copy
      else
        return full-json
    else
      return null
  if format instanceof Object
    copy = {}
    for key, val of format
      if format.hasOwnProperty(key) && full-json.hasOwnProperty(key)
        copy[key] = clean-json full-json[key], format[key]
    return copy;  
  throw new Error "type isn't supported."
    
module.exports <<< filter
