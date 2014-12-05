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
        @map (o) -> o.start()
        @

    reset: ->
        @map (o) -> o.reset()
        @

    set: (args...) ->
        @map (o) -> o.set.apply o, args
        @

    trigger: (args...) ->
        if @enabled then @map (o) -> o.trigger.apply o, args
        @

    enable: ->
        @enabled = yes
        @

    disable: (silent) ->
        @enabled = no
        @

    map: (cb) ->
        cb(o) for o in @managers
        @


module.exports = StatsManager
