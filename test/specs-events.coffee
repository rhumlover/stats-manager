chai = require 'chai'
expect = chai.expect

StatsManager = require '../src/stats-manager'
Plugin = require '../src/plugin'

describe 'StatsManager > Plugin > Events', ->

    sm = new StatsManager()
    plugin = new Plugin()
    plugin.set 'loaded', yes
    sm.register plugin
    sm.start()

    it 'should listen to a simple event', ->
        plugin.listen('simple.event')
            .then((data) ->
                expect(data.received).to.equal yes
            )

        sm.trigger 'simple.event', { received: yes }


    it 'should filter the data (positive)', ->
        received = no

        plugin.listen('filter.positive')
            .filter((data) -> data.filter is yes)
            .then((data) -> received = yes)

        sm.trigger 'filter.positive', { filter: yes }
        expect(received).to.equal yes


    it 'should filter the data (negative)', ->
        received = no

        plugin.listen('filter.negative')
            .filter((data) -> data.filter isnt yes)
            .then((data) -> received = yes)

        sm.trigger 'filter.negative', { filter: yes }
        expect(received).to.equal no


    it 'should queue multiple `.then()`', ->
        plugin.listen('chained.then')
            .then((data) -> data.received++)
            .then((data) -> data.received++)
            .then((data) -> data.received++)
            .then((data) ->
                expect(data.received).to.equal 3
            )

        sm.trigger 'chained.then', { received: 0 }


    it 'should run .async() method', (done) ->
        plugin.listen('async')
            .async((sm_done) ->
                setTimeout ->
                    sm_done({ received: yes })
                , 100
            )
            .then((data) ->
                expect(data.received).to.equal yes
                done()
            )

        sm.trigger 'async'
