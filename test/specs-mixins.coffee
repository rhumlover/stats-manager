chai = require 'chai'
expect = chai.expect

StatsManager = require '../src/stats-manager'
Plugin = require '../src/plugin'

describe 'StatsManager > Plugin > Mixins', ->

    sm = new StatsManager()
    plugin = new Plugin()
    plugin.set 'loaded', yes
    sm.register plugin
    sm.start()

    it 'should register a mixin', ->
        plugin.mixin('return.true', -> yes)
        true

    it 'should use a mixin', ->
        plugin.listen('mixin')
            .then(-> expect(@include 'return.true').to.equal yes)
        sm.trigger 'mixin'

    it 'should\'nt override plugin property/ method with an existing name', ->
        originalMethod = plugin.mixin
        newMethod = -> yes

        plugin.mixin('mixin', newMethod)
        expect(plugin.mixin).to.equal originalMethod
