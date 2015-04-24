class StatsManager

    constructor: (eventList) ->
        @setEvents eventList
        @managers = []
        @enabled = yes

    setEvents: (eventList) ->
        return if not eventList? and not Array.isArray eventList
        eventList.forEach @setEvent.bind @
        @

    setEvent: (evt) ->
        return if typeof evt isnt 'string'
        @[evt] = evt
        StatsManager[evt] = evt
        @

    register: (statPluginManager) ->
        @managers.push statPluginManager
        @

    start: ->
        @managers.forEach (m) -> m.start()
        @

    reset: ->
        @managers.forEach (m) -> m.reset()
        @

    trigger: (args...) ->
        if @enabled
            @managers
                .filter((m) -> m.enabled)
                .forEach((m) -> m.trigger.apply m, args)
        @

    enable: ->
        @enabled = yes
        @

    disable: ->
        @enabled = no
        @

    set: (key, value, options) ->
        @managers.forEach (m) -> m.set key, value, options
        @


module.exports = StatsManager
