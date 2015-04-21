Eventer = require './utils/eventer.coffee'

class Store extends Eventer

    constructor: (data) ->
        @data = data ? {}
        super data

    set: (key, value, silent = false) ->
        oldValue = @data[key] ? null
        @data[key] = value

        if not silent
            @emit "change:#{key}", {
                oldValue: oldValue
                newValue: value
            }
            @emit "change", {
                key: key
                value: value
            }

    get: (key) ->
        if @data.hasOwnProperty key
            return @data[key]
        null

    has: (key) ->
        !!@get[key]


module.exports = Store
