Eventer = require './utils/eventer.coffee'
EventStream = require './utils/eventstream.coffee'
Session = require './utils/session.coffee'
Store = require './store.coffee'

class Plugin

    constructor: (@options = {}) ->
        @_triggerQueue = []
        @_mixins = {}
        @_eventBus = new Eventer()
        @_data = new Store()

        @session = new Session()
        @enabled = yes

        if @options.sampling?
            return if not @setSampling @options.sampling

        onModelChange = (model, data, options) =>
            if @isReady()
                _unqueue.call @
                @_data.off 'change', onModelChange

        @_data.on 'change', onModelChange
        @_data.on 'change:loaded', (model, value, options) =>
            @onLoad?() if value is true
            return

        @initialize?()

    start: ->
        @set 'started', yes
        @

    _unqueue = ->
        if @_triggerQueue.length
            console.log '%c[%s] Plugin ready, unqueuing events %O', 'font-weight: bold;', @displayName, @_triggerQueue
            ((queue) =>
                for queueItem in queue
                    @trigger.apply @, queueItem
                return
            )(@_triggerQueue)
        @

    isReady: ->
        @get('started') is yes and @get('loaded') is yes

    setSampling: (isInSample) ->
        @enabled = if isInSample?() is no then no else yes


    # ---------------------------------------
    # DATA
    # ---------------------------------------
    get: (key) ->
        @_data.get key

    set: (key, value, options) ->
        @_data.set key, value, options

    unset: (key) ->
        @_data.unset key

    has: (key) ->
        @_data.get(key)?


    # ---------------------------------------
    # EVENTS
    # ---------------------------------------
    trigger: (e) ->
        if not e? or not @enabled then return @
        if not @isReady()
            console.log '%c[%s] Plugin not ready, queuing event `%s`', 'font-weight: bold;', @displayName, e
            @_triggerQueue.push arguments
            return @

        @_eventBus.trigger.apply @_eventBus, arguments
        @

    listen: (eventName) ->
        str = new EventStream @
        @_eventBus.on eventName, str.run.bind(str)
        str


    # ---------------------------------------
    # HELPERS
    # ---------------------------------------
    mixin: (name, fn) ->
        @_mixins[name] = fn
        @[name] = fn.bind(@)
        @

    include: (name, args...) ->
        if fn = @_mixins[name]
            return fn.apply @, args
        @

    loadPlugin: (pluginUrl) ->
        self = @

        cs = document.createElement 'script'
        cs.type = 'text/javascript'
        cs.async = true
        cs.src = pluginUrl

        loaded = false
        cs.onload = cs.onreadystatechange = ->
            if not loaded and (not @readyState or @readyState is 'loaded' or @readyState is 'complete')
                loaded = true

                self.onPluginLoaded?()

                # Avoid memory leak in IE
                cs.onload = cs.onreadystatechange = null
                if cs.parentNode then cs.parentNode.removeChild cs
                console.log '%c[%s] script loaded successfully (%s)', 'font-weight: bold;', self.displayName, pluginUrl
                self.set 'loaded', yes
            return

        cs.onerror = ->
            console.warn '%cError loading script at %s', 'font-weight: bold;', pluginUrl
            return

        s = document.getElementsByTagName('script')[0]
        s.parentNode.insertBefore cs, s
        @

module.exports = Plugin
