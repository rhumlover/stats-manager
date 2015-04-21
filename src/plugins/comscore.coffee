Plugin = require '../plugin.coffee'

_consoleColor = 'color: purple;'

class ComScorePlugin extends Plugin

    _pluginUrl: (if @_is_https then 'https://sb' else 'http://b') + '.scorecardresearch.com/beacon.js'

    initialize: (options = {}) ->
        {pluginUrl} = options
        pluginUrl = @_pluginUrl unless pluginUrl?

        _cs = window.COMSCORE
        @queue = if _cs then false else []

        if not _cs
            console.log '%c[CS] COMSCORE not present, loading plugin at %s', _consoleColor, pluginUrl
            @loadPlugin pluginUrl
        else
            @set 'loaded', yes

    isLoaded: ->
        window.COMSCORE?

    onLoad: ->
        @enabled = @isLoaded()
        @

    track: (data) ->
        console.log '%c[CS] Tracking data %s', _consoleColor, JSON.stringify(data)
        beacon = window.COMSCORE.beacon
        beacon data


module.exports = ComScorePlugin
