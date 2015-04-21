class StatsManager

    constructor: (eventList) ->
        @setEvents eventList
        @managers = []
        @enabled = yes

    setEvents: (@eventList) ->
        return unless eventList?

        for e in eventList
            @[e] = e
            StatsManager[e] = e
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


module.exports = StatsManager
