class StatsManager

    constructor: (eventList) ->
        @events = {}
        @managers = []
        @enabled = yes

        if Array.isArray eventList
            reduceToObject = (acc, evt) ->
                acc[evt] = evt
                acc

            @events = eventList.reduce reduceToObject, @events

    register: (statPlugin) ->
        @managers.push statPlugin
        @

    start: ->
        @managers.forEach (m) -> m.start()
        @

    reset: ->
        @managers.forEach (m) -> m.reset()
        @

    trigger: (args...) ->
        return @ unless @enabled
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
