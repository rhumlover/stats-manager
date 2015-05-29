Eventer = require './utils/eventer.coffee'

class Store extends Eventer

    constructor: (data) ->
        @data = data ? {}
        super

    set: (key, value, options = {}) ->
        oldValue = @data[key] ? null
        @data[key] = value

        unless options.silent
            @emit "change:#{key}", @, value, options
            @emit "change", @, {
                key: key
                oldValue: oldValue
                newValue: value
            }, options

    get: (key) ->
        if @data.hasOwnProperty key
            return @data[key]
        null

    has: (key) ->
        !!@get[key]

    unset: (key) ->
        delete @data[key]

module.exports = Store
