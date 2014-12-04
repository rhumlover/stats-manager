Plugin = require '../plugin.coffee'

_consoleColor = 'color:red;'

class GoogleAnalyticsUniversalPlugin extends Plugin

    initialize: (options) ->
        {account,domain,options} = @options

        if not account?
            # console.warn 'GoogleAnalyticsUniversalPlugin: You must define an account'
            return @

        if 'ga' not of window
            # console.log '%c[GA] Google Analytics (ga) not present, loading plugin at %s', _consoleColor, '//www.google-analytics.com/analytics.js'
            ((i, s, o, g, r, a, m) ->
                i['GoogleAnalyticsObject'] = r;
                i[r] = i[r] or ->
                    (i[r].q = i[r].q or []).push arguments
                    return
                i[r].l = 1 * new Date()
                a = s.createElement(o)
                m = s.getElementsByTagName(o)[0]
                a.async = 1
                a.src = g
                m.parentNode.insertBefore(a, m)
                return
            )(window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga')

        @set 'loaded', yes

        options ?= {}

        domain ?= 'auto'
        createParam = ['create', account, domain, options]
        @track createParam
        @

    track: (parameters) ->
        _ga = window.ga
        _ga.apply _ga, parameters
        @

    trackEvent: (category, action, opt_label, opt_value, opt_noninteraction) ->
        param = ['send', 'event', category, action]
        if opt_label? then param.push opt_label
        if opt_value? then param.push opt_value
        if opt_noninteraction? then param.push { nonInteraction: 1 }
        @track param
        # console.log '%c[GA] Tracking event %s', _consoleColor, JSON.stringify(param)
        @

    trackTiming: (category, variable, time, opt_label, opt_sampleRate) ->
        # To Avoid tracking bad data, time must be > 0 and < 1 hour (in milliseconds)
        if 0 < time < (1000*60*60)
            param = ['send', 'timing', category, variable, time]
            if opt_label? then param.push opt_label
            if opt_sampleRate? then param.push opt_sampleRate
            @track param
            # console.log '%c[GA] Tracking timing %s', _consoleColor, JSON.stringify(param)
        @

    trackPageview: (options = {}) ->
        @track ['send', 'pageview', options]
        # console.log '%c[GA] Tracking page view', _consoleColor, options
        @

    # Aliases
    @::trackPageView = @::trackPageview


module.exports = GoogleAnalyticsUniversalPlugin
