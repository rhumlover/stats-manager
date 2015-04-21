Plugin = require '../plugin.coffee'

_consoleColor = 'color: orange;'

class GemiusPlugin extends Plugin

    _window = window

    _pluginUrl: '//gatr.hit.gemius.pl/xgemius.js'

    initialize: (options = {}) ->
        {pluginUrl, identifier} = options
        pluginUrl = @_pluginUrl unless pluginUrl?

        _window.pp_gemius_identifier = identifier
        @track 'gemius_hit'
        @track 'gemius_event'
        @track 'pp_gemius_hit'
        @track 'pp_gemius_event'

        @loadPlugin pluginUrl

    track: (i) ->
        console.log '%c[GEMIUS] Tracking data %s', _consoleColor, JSON.stringify(data)
        _window[i] = _window[i] or ->
            x = _window[i+'_pdata'] = _window[i+'_pdata'] or []
            x[x.length] = arguments

module.exports = GemiusPlugin
