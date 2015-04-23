chai = require 'chai'
expect = chai.expect

StatsManager = require '../src/stats-manager'
Plugin = require '../src/plugin'

describe 'StatsManager > Plugin > Initialization', ->

    describe 'Blank state', ->

        sm = new StatsManager()
        plugin = new Plugin()
        sm.register plugin

        it 'shouldn\'t receive anything if plugin isn\'t loaded', ->
            received = no
            plugin.listen('init.not.loaded')
                .then(-> received = yes)

            sm.trigger 'init.not.loaded'
            expect(received).to.equal no

        it 'shouldn\'t receive anything if plugin isn\'t started', ->
            received = no
            plugin.listen('init.not.started')
                .then(-> received = yes)

            sm.trigger 'init.not.started'
            expect(received).to.equal no

        it 'should trigger a custom `.onLoad()` method when loaded', ->
            loaded = no
            plugin.onLoad = -> loaded = yes
            plugin.set 'loaded', yes
            expect(loaded).to.equal yes


    describe 'Started and loaded', ->

        sm = new StatsManager()
        plugin = new Plugin()
        sm.register plugin

        queued = 0

        before ->
            plugin.listen('queue1').then(-> queued++)
            plugin.listen('queue2').then(-> queued++)
            return

        it 'should queue events until plugin is loaded and started', ->
            sm.trigger 'queue1'
            sm.trigger 'queue2'
            expect(queued).to.equal 0

        it 'should unqueue events when plugin is ready', ->
            plugin.set 'loaded', yes
            sm.start()
            expect(queued).to.equal 2
