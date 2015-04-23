chai = require 'chai'
expect = chai.expect

StatsManager = require '../src/stats-manager'
Plugin = require '../src/plugin'

describe 'StatsManager > Plugin > Sampling', ->

    sm = new StatsManager()
    plugin = new Plugin()
    plugin.set 'loaded', yes
    sm.register plugin
    sm.start()

    it 'should work when in sample', ->
        enabled = no
        plugin.setSampling -> yes
        plugin.listen('in.sample')
            .then(-> enabled = yes)

        sm.trigger 'in.sample'
        expect(enabled).to.equal yes

    it 'shouldn\'t work when out of sample', ->
        enabled = no
        plugin.setSampling -> no
        plugin.listen('out.of.sample')
            .then(-> enabled = yes)

        sm.trigger 'out.of.sample'
        expect(enabled).to.equal no
