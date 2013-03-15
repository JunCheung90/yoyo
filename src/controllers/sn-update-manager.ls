require! ['../models/sn-update']
require! ['../util']

Sn-update-manager =
  client-get-sn-update: !(req-parms, callback) ->
    (err, sn-update-result) <-! sn-update.client-get-sn-update req-parms
    callback {result-code: -1, error-message: err} if err
    callback {result-code: 0, client-sn-update: sn-update-result}

module.exports <<< Sn-update-manager