StatsManager
=============

StatsManager is a client-side Tag Management System (TMS) designed to work as a chainable Stream Flow:

```
stats_plugin.listen(event)
    .filter((data) -> true/false)
    .async((data, done) -> done(data))
    .then((data) -> data.var1 = 1)
    .then((data) -> @track data)

... Then elsewhere, in your controllers:

statsmanager.trigger('ping', { data })
```
## Installation

```
$ git clone git@github.com:rhumlover/stats-manager.git
$ npm install
```

## Tests

```
$ npm test
```

### Development environment

When working on the sources, you can setup a dev environment that will do the following:

- build webpack and watch for changes (`ENV_DEV=1 BUILD_VAR=1 webpack --watch -d`)
- run a local server on localhost:8080 (`coffee server.coffee`)
- run mocha and run tests on each file change (`mocha --watch --reporter spec test/*.coffee`)

### Building for dev

It will create a debug version in the `./dist/` directory and watch for the changes *(eq. webpack -d --watch)*

```
$ npm run-script dev:var
// exposes the library as a top-level variable

$ npm run-script dev:umd
// exports the library as a module (compatible with AMD or CommonJS)
```

### Building for production

It will create a production-ready version in the `./dist/` directory: minified, with all `console` calls stripped *(eq. webpack -p)*

```
$ npm run-script build:var
// exposes the library as a top-level variable

$ npm run-script build:umd
// exports the library as a module (compatible with AMD or CommonJS)
```

## Main Objects

```
- StatsManager
    .plugins
        .ComScorePlugin
        .GemiusPlugin
        .GoogleAnalyticsPlugin
        .SiteCatalystPlugin
```

### StatsManager

```
StatsManager = require 'StatsManager'
SiteCatalystPlugin = StatsManager.plugins.SiteCatalystPlugin
GoogleAnalyticsPlugin = StatsManager.plugins.GoogleAnalyticsPlugin

// Define available events
eventList = [
    "START"
    "PAUSE"
    "STOP"
    "END"
]

// Instanciate the main StatsManager
statsManager = new StatsManager(eventList)

// create plugin instances
plugin_SC = new SiteCatalystPlugin()
plugin_GA = new GoogleAnalyticsPlugin()

// Register plugins
statsManager.register plugin_SC
statsManager.register plugin_GA

// Start listening
statsManager.start()

```

### Plugins

Global plugins constructor options:

- sampling: a **function** returning true or false, defining if the plugin is activated or not. 
  Returning `false` means the session will be out of the sample, so deactivated.

```
plugin_GA = new GoogleAnalyticsPlugin({
    account: 'UA-XXXXX-XX'
    domain: 'your-domain.com'
    sampling: -> location.hostname is 'github.com'
})
```

#### GoogleAnalyticsPlugin
```
plugin_GA = new GoogleAnalyticsPlugin({
    account: 'UA-XXXXX-XX'
    domain: 'your-domain.com'
})

plugin_GA.listen(@PAGE_CHANGE)
    .then((data) ->
        @trackPageview {
            'page': data.location
            'title': data.page
        }
    )
```
Constructor options: 

- `account`
- `domain`

Available methods (basically a mapping of Google's ones):

- `track(data)`
- `trackPageView(data)`
- `trackEvent(category, action, opt_label, opt_value, opt_noninteraction)`
- `trackTiming(category, variable, time, opt_label, opt_sampleRate)`

#### SiteCatalystPlugin
```
plugin_SC = new SiteCatalystPlugin({
    s_account: window.s_account
    pluginUrl: 'http://your-domain/s_code.js'
    sampling: -> Math.random() < 0.25
})

plugin_SC.listen(@PAGE_CHANGE)
    .then((data) ->
        @track {
            eVar1: data.eVar1
            prop2: data.prop2            
        }
    )
```
Constructor options: 

- `s_account`: your `s_account` id provided by SiteCatalyst
- `pluginUrl`: your `s_code` hosted url

Available methods:


- `setData(data)`: merge data into the global `s` var
- `track(data)`: merge data into the global `s` var and calls `s.t()`
- `trackEvent(data)`: merge data into the global `s` var and calls `s.tl()`
- `reset(force = false)`: reset all sProps and events of `s`. Forcing will also reset all eVars

#### ComScorePlugin
```
plugin_CS = new ComScorePlugin()

plugin_CS.listen(@PAGE_CHANGE)
    .filter((data) -> data.page isnt 'Home')
    .then((data) ->
        @track {
            c1: 1
            c2: "123456789"
        }
    )
```
Constructor options: 

- `pluginUrl`: the comscore beacon url. Defaults to 'http://b.scorecardresearch.com/beacon.js'

Available methods:

- `track(data)` calls `window.COMSCORE.beacon(data)`


## Stream Flow

Several chained methods are available:

```
plugin.listen(event)
    .filter((data) -> true/false)
    .async((data, done) -> done(data))
    .then((data) -> @track...)
```

- **listen:** creates a stream flow by listening an event. It's the only one not chainable, the startpoint of all the stream flow
- **filter:** the provided callback will have to return a boolean. It's a convenient way to perform some tests and filter the flow. A `false` will not perform the next step.
- **async:** inspired by Mocha tests. The provided callback will have to include a `done` var as last argument, and this `done` is a function you'll need to call when you're ready to go to the next step. Pass all next step datas in the call
- **then:** a basic synchronous 'step' in your flow. The callback gives you access to the current flow's datas. You have to return the datas you want to pass to the next step. 

All methods **except listen** can be chained multiple times. You could call a hundred async in a row if you'd like, I hope you're not really thinking about that though =D

## Mixins

Mixins are helpers functions you can register to a plugin, and use (include) anytime you want within the stream flow callbacks. Ex:

```
plugin_GA = new GoogleAnalyticsPlugin({
    account: 'UA-XXXXX-XX'
    domain: 'mydomain.com'
})

plugin_GA.mixin 'getLocation', () ->
    location.pathname or '/'

plugin_GA.listen(@PAGE_CHANGE)
    .then((data) ->
        @trackPageview {
            'page': @include 'getLocation'
            'title': data.page
        }
    )
```

## Integration example
```
(function() {
    var ComScorePlugin, StatsManager, plugin_cs, sm;

    // CommonJS
    StatsManager = require('StatsManager');

    // Library
    StatsManager = window.StatsManager;

    ComScorePlugin = StatsManager.plugins.ComScorePlugin;

    sm = new StatsManager(['ping']);

    plugin_cs = new ComScorePlugin();
    plugin_cs.listen('ping')
        .then(function(data) {
            console.log(data);
        });

    sm.register(plugin_cs);
    sm.start();

    sm.trigger('ping', { 'success': 'yes!' });

    >> Object {success: "yes!"}
})();
```
