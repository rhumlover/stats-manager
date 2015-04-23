Plugin = require '../plugin.coffee'

_consoleColor = 'color: orange;'

class GemiusPlugin extends Plugin

    displayName: 'GemiusPlugin'

    _window = window
    _pluginUrl: '//gatr.hit.gemius.pl/xgemius.js'

    initialize: (options = {}) ->
        {pluginUrl, identifier, hits} = options
        pluginUrl = @_pluginUrl unless pluginUrl?

        unless identifier?
            console.warn 'GemiusPlugin: You must define an identifier to use the plugin.'
            @enabled = no
            return @

        _window.pp_gemius_identifier = identifier

        if hits? and Array.isArray hits
            hits.forEach @track.bind @

        @loadPlugin pluginUrl

    track: (i) ->
        console.log '%c[GEMIUS] Tracking data %s', _consoleColor, i
        _window[i] = _window[i] or ->
            x = _window[i+'_pdata'] = _window[i+'_pdata'] or []
            x[x.length] = arguments

module.exports = GemiusPlugin
