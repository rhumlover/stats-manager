Plugin = require '../plugin.coffee'
Mixins = require '../utils/mixins.coffee'

_consoleColor = 'color:blue;'

class SiteCatalystPlugin extends Plugin

    initialize: (options) ->
        @s = null
        # @trackData = {}

        {@s_account,pluginUrl} = @options
        window.s_account = @s_account

        if not @isLoaded()
            # console.log '%c[SC] SiteCatalyst (s) not present, loading plugin at %s', _consoleColor, pluginUrl
            @loadPlugin pluginUrl
        else
            # console.log '> Plugin for %s loaded', @
            @set 'loaded', yes

    isLoaded: ->
        window.SiteCatalyst?

    onLoad: ->
        if @isLoaded()
            @s = window.SiteCatalyst.getInstance()
            @media = @s.media
        else
            @enabled = no
        @

    setRSID: (rsid) ->
        if not 'SiteCatalyst' of window then return
        @s.un = rsid
        @

    setData: (data) ->
        # console.log '%c[SC] Extending', _consoleColor, data
        # _.assign @trackData, data
        _.assign @s, data
        @

    reset: () ->
        _reset = {}

        for x in [1..75]
            key = "prop#{x}"
            _reset[key] = '' if @s.hasOwnProperty(key)

        @setData _reset
        # console.log '%c[SC] Reseting all vars', _consoleColor
        @

    track: (data) ->
        @setData data if data?
        # console.log '%c[SC] Tracking: sending s.t() with', _consoleColor, _.extend({}, @trackData)
        @s.t()
        @reset()
        @

    trackEvent: (data, title) ->
        @setData data if data?
        # console.log '%c[SC] Tracking event: sending s.tl() with', _consoleColor, _.extend({}, @trackData)
        @s.tl @s, 'o', title
        @reset()
        @


module.exports = SiteCatalystPlugin
