class Session

    constructor: ->
        @history = []
        @data = {}

    log: ->
        @history.push JSON.stringify(arguments)
        return this

    hasLog: (e) ->
        for log in @history
            if ~log.indexOf '"' + e + '"' then return true
        return false

    save: (key, value) ->
        @data[key] = value
        return this

    get: (key) ->
        return if key of @data then @data[key] else null

    has: (key) ->
        !!(key of @data)


module.exports = Session
