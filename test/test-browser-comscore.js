(function(window) {
    var expect = chai.expect;

    describe('StatsManager > ComScorePlugin', function() {
        var StatsManager = window.StatsManager,
            ComScorePlugin = StatsManager.plugins.ComScorePlugin,
            sm, plugin_cs;

        before(function() {
            sm = new StatsManager();
            plugin_cs = new ComScorePlugin();
            sm.register(plugin_cs);
            sm.start()
        });

        it('should send a basic event', function(done) {
            plugin_cs.listen('page-change')
                .then(function(data) {
                    this.track({
                        c1: 1,
                        c2: 'c2'
                    });
                    done();
                });

            sm.trigger('page-change', {
                title: 'Home'
            });
        });
    });
})(this);
