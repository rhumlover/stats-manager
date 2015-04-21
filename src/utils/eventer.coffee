class Eventer

    constructor: ->
        @_events = {}

    on: (evt, callback, context, once = false) ->
        if not callback?
            console.warn 'You cannot register to an event without specifying a callback'
            return

        list = evt.split ' '
        for e in list
            _on.call @, e, callback, context, once
        @

    _on = (evt, callback, context, once = false) ->
        @_events[evt] ?= []
        @_events[evt].push {
            name: evt
            callback: callback
            context: context or @
            once: once
        }

    off: (evt, callback) ->
        if hasNs = evt.match /^(\.|:)[0-9a-zA-Z_-]+$/
            _removeNS.call @, evt
        else
            _removeEvents.call @, evt, callback
        @

    _removeEvents = (evt, callback) ->
        if listeners = @_events[evt]
            i = listeners.length
            while i--
                item = listeners[i]
                if not callback? or item.callback is callback
                    listeners.splice i, 1
        @

    _removeNS = (namespace) ->
        eventList = Object.keys @_events
        for evt in eventList
            if !!~evt.indexOf(namespace)
                delete @_events[evt]
        @

    once: (evt, callback, context) ->
        @on evt, callback, context, true
        @

    trigger: (evt, data...) ->
        onces = []
        if listeners = @_events[evt]
            for item in listeners
                item.callback.apply item.context, data
                if item.once
                    onces.push item

        if onces.length
            for item in onces
                listeners.splice listeners.indexOf(item), 1
        @

    reset: ->
        @_events = {}

# Aliases
Eventer::emit = Eventer::trigger


module.exports = Eventer
