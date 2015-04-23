chai = require 'chai'
expect = chai.expect

StatsManager = require '../src/stats-manager'
Plugin = require '../src/plugin'

describe 'StatsManager > Plugin > Data', ->

    sm = new StatsManager()
    plugin = new Plugin()
    plugin.set 'loaded', yes
    sm.register plugin
    sm.start()

    it 'should save some data in the plugin between events', ->
        plugin.listen('data.save1')
            .then(-> @set 'saved', yes)

        plugin.listen('data.save2')
            .then(->
                expect(@get 'saved').to.equal yes
            )

        sm.trigger 'data.save1'
        sm.trigger 'data.save2'


    it 'should be able to remove a key in the plugin data', ->
        plugin.set 'to-remove', yes
        plugin.listen('data.remove')
            .then(-> plugin.unset 'to-remove')

        sm.trigger 'data.remove'
        expect(plugin.get 'to-remove').to.equal null
