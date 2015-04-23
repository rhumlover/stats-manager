var StatsManager = require('./src/stats-manager.coffee');

StatsManager.plugins = {
    ComScorePlugin: require('./src/plugins/comscore.coffee'),
    GemiusPlugin: require('./src/plugins/gemius.coffee'),
    GoogleAnalyticsPlugin: require('./src/plugins/googleanalytics.coffee'),
    SiteCatalystPlugin: require('./src/plugins/sitecatalyst.coffee')
}

module.exports = StatsManager;
