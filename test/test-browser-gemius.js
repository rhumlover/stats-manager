(function(window) {
    var expect = chai.expect;

    describe('StatsManager > GemiusPlugin', function() {
        var StatsManager = window.StatsManager,
            GemiusPlugin = StatsManager.plugins.GemiusPlugin,
            sm, plugin_gm;

        before(function() {
            sm = new StatsManager();
            plugin_gm = new GemiusPlugin();
            sm.register(plugin_gm);
            sm.start()
        });

        it('should initialize GemiusPlugin', function(done) {
            plugin_gm.listen('page-change')
                .then(function() {
                    done();
                });

            sm.trigger('page-change', {
                title: 'Home'
            });
        });
    });
})(this);
