Mixins =
    isObject: (value) ->
        type = typeof value
        value and (type is 'function' or type is 'object') or false


    extend: (object, source, guard) ->
        args = arguments
        argsIndex = 0
        argsLength = args.length
        type = typeof guard

        # allows working with functions like `_.reduce` without using their
        # `key` and `object` arguments as sources
        argsLength = 2 if (type is "number" or type is "string") and args[3] and args[3][guard] is source

        # juggle arguments
        while ++argsIndex < argsLength
            source = args[argsIndex]
            if isObject source
                index = -1
                props = keys(source)
                length = props.length
                while ++index < length
                    key = props[index]
                    object[key] = source[key]
        object


    value: (input) ->
        if typeof input is 'function'
            return input()
        input


module.exports = Mixins
