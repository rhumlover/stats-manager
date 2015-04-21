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

        onModelChange = (model, options) =>
            if @isReady()
                console.log '%c$ %s is ready !', 'font-weight:bold;', @
                _unqueue.call @
                @_data.off 'change', onModelChange

        @_data.on 'change', onModelChange
        @_data.on 'change:loaded', (model, value, options) =>
            @onLoad?() if value is true
            return

        @initialize?()

    start: ->
        console.log '$ Starting %s', @
        @set 'started', yes
        @

    _unqueue = ->
        if @_triggerQueue.length
            ((queue) =>
                for queueItem in queue
                    console.log '$ Unqueuing %s on %s', queueItem[0], @
                    @trigger.apply @, queueItem
                return
            )(@_triggerQueue)
        @

    isReady: ->
        @get('started') is yes and @get('loaded') is yes

    setSampling: (isInSample) ->
        if isInSample?() isnt true
            console.log '%c⚠ Plugin %s is not sampled and has been disabled', 'font-weight: bold', @
            @enabled = no
        @enabled


    # ---------------------------------------
    # DATA
    # ---------------------------------------
    get: (key) ->
        @_data.get key

    set: (key, value, options) ->
        @_data.set key, value, options

    remove: (key) ->
        @_data.unset key

    has: (key) ->
        @_data.get(key)?


    # ---------------------------------------
    # EVENTS
    # ---------------------------------------
    trigger: (e) ->
        if not e? or not @enabled then return @
        if not @isReady()
            @_triggerQueue.push arguments
            return @

        console.log '$ Trigerring %s on %s', e, @
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
                console.log '> Plugin for %s loaded', self

                self.onPluginLoaded?()

                # Avoid memory leak in IE
                cs.onload = cs.onreadystatechange = null
                if cs.parentNode then cs.parentNode.removeChild cs
                self.set 'loaded', yes
            return

        cs.onerror = ->
            # console.warn '%cError loading script at %s', 'font-weight: bold;', pluginUrl
            return

        s = document.getElementsByTagName('script')[0]
        s.parentNode.insertBefore cs, s
        @


module.exports = Plugin
