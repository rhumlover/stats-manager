Eventer = require './utils/eventer.coffee'

class Store extends Eventer

    constructor: (data) ->
        @data = data ? {}

    set: (key, value, silent = false) ->
        oldValue = @data[key] ? null
        @data[key] = value

        if not silent
            @emit "change:#{key}", {
                oldValue: oldValue
                newValue: value
            }

    get: (key) ->
        if @data.hasOwnProperty key
            return @data[key]
        null


module.exports = Store
