(function(window) {
    var expect = chai.expect;

    describe('StatsManager > GoogleAnalyticsPlugin', function() {
        var StatsManager = window.StatsManager,
            GoogleAnalyticsPlugin = StatsManager.plugins.GoogleAnalyticsPlugin,
            sm, plugin_ga;

        before(function() {
            sm = new StatsManager();
            plugin_ga = new GoogleAnalyticsPlugin({
                account: 'UA-11111-11'
            });
            sm.register(plugin_ga);
            sm.start()
        });

        it('should send a pageview event and receive a hit callback', function(done) {
            plugin_ga.listen('page-change')
                .then(function(data) {
                    this.trackPageView({
                        'page': location.pathname,
                        'title': data.title,
                        'hitCallback': done
                    });
                });

            sm.trigger('page-change', {
                title: 'Home'
            });
        });
    });
})(this);
