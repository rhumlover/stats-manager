(function(window) {
    var expect = chai.expect;

    describe('StatsManager > SiteCatalystPlugin', function() {
        var StatsManager = window.StatsManager,
            SiteCatalystPlugin = StatsManager.plugins.SiteCatalystPlugin,
            sm, plugin_sc;

        before(function() {
            sm = new StatsManager();
            plugin_sc = new SiteCatalystPlugin({
                s_account: 'your.s_account',
                pluginUrl: 'http://s2.dmcdn.net/KEwea.js'
            });
            sm.register(plugin_sc);
            sm.start()
        });

        it('should send a track ping', function(done) {
            plugin_sc.listen('page-change')
                .then(function(data) {
                    this.track({
                        'prop1': 'prop1',
                        'eVar1': 'eVar1'
                    });
                    done();
                });

            sm.trigger('page-change', {});
        });
    });
})(this);
