class EventStreamOperation

    constructor: (@name, @context, @fn) ->
        @next = null

    run: (args...) ->
        if @name is 'async'
            args.push @done.bind(@)
            @fn.apply @context, args
            return

        if @name is 'filter'
            res = @fn.apply @context, args
            if res is true then @next?.run.apply @next, args
            return

        if @name is 'then'
            res = @fn.apply @context, args
            @next?.run.apply @next, args
            return

    done: (args...) ->
        @next?.run.apply @next, args


class EventStream

    constructor: (@context) ->
        @ops = []
        @data = null
        @current = null

    register: (name, fn) ->
        nextOp = new EventStreamOperation name, @context, fn

        do =>
            currentOpIndex = @ops.length - 1
            if currentOpIndex >= 0
                currentOp = @ops[currentOpIndex]
                currentOp.next = nextOp

        @ops.push nextOp

    run: (args...) ->
        sanitized = args.filter (i) -> i?
        if @ops.length
            firstOp = @ops[0]
            firstOp.run.apply firstOp, sanitized
        @

    filter: (operation) ->
        self = @
        @register 'filter', (args...) ->
            try
                res = operation.apply self.context, args
                return res
            catch e
                return false
            true
        @

    then: (callback) ->
        @register 'then', callback
        @

    async: (callback) ->
        @register 'async', callback
        @


module.exports = EventStream
