var StatsManager = require('./src/stats-manager.coffee');

StatsManager.plugins = {
    ComScorePlugin: require('./src/plugins/comscore.coffee'),
    GoogleAnalyticsPlugin: require('./src/plugins/googleanalytics.coffee'),
    SiteCatalystPlugin: require('./src/plugins/sitecatalyst.coffee')
}

module.exports = StatsManager;
