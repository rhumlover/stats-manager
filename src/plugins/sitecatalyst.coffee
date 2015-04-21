Plugin = require '../plugin.coffee'

_consoleColor = 'color:blue;'

class SiteCatalystPlugin extends Plugin

    initialize: (options) ->
        @s = null
        @trackData = {}

        {@s_account, pluginUrl} = @options

        if not pluginUrl?
            console.warn 'SiteCatalystPlugin: You must define a plugin_url to use the plugin.'
            @enabled = no
            return @

        if not s_account?
            console.warn 'SiteCatalystPlugin: You must define a s_account to use the plugin.'
            @enabled = no
            return @

        if not @isLoaded()
            console.log '%c[SC] SiteCatalyst (s) not present, loading plugin at %s', _consoleColor, pluginUrl
            @loadPlugin pluginUrl
        else
            console.log '> Plugin for %s loaded', @
            @set 'loaded', yes

    isLoaded: ->
        window.SiteCatalyst?

    onLoad: ->
        if @isLoaded()
            @s = window.SiteCatalyst.factory({ @s_account })
            @media = @s.media
        else
            @enabled = no
        @

    setRSID: (rsid) ->
        if not 'SiteCatalyst' of window then return
        @s.un = rsid
        @

    setData: (data) ->
        console.log '%c[SC] Extending', _consoleColor, data
        Object.keys(data).forEach((key) ->
            @trackData[key] = data[key]
            @s[key] = data[key]
        )
        @

    reset: (force = false) ->
        _reset = {}

        for x in [1..75]
            prop = "prop#{x}"
            _reset[prop] = '' if @s.hasOwnProperty(prop)

            if force is true
                eVar = "eVar#{x}"
                _reset[eVar] = '' if @s.hasOwnProperty(eVar)

        _reset['events'] = ''

        @setData _reset
        console.log '%c[SC] Reseting all props and events', _consoleColor
        @

    track: (data) ->
        @setData data if data?
        console.log '%c[SC] Tracking: sending s.t() with', _consoleColor, _.extend({}, @trackData)
        @s.t()
        @reset()
        @

    trackEvent: (data, title) ->
        @setData data if data?
        console.log '%c[SC] Tracking event: sending s.tl() with', _consoleColor, _.extend({}, @trackData)
        @s.tl @s, 'o', title
        @reset()
        @


module.exports = SiteCatalystPlugin
