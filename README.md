StatsManager
=============

StatsManager is a client-side Tag Management System (TMS) designed to work as a chainable Stream Flow:

```
stats_plugin.listen(event)
    .filter((data)-> true/false)
    .async((data, done) -> done(data))
    .then((data) -> data.var1 = 1; return data)
    .then((data) -> @track data)
```
## Installation

### Local project

```
$ git clone git@github.com:rhumlover/stats-manager.git
$ cd stats-manager
$ ls dist/
stats-manager.js             stats-manager.require.js
stats-manager.min.js         stats-manager.require.min.js
```
- `stats-manager.js` is web version of the library. It exposes a StatsManager object containing all main objects you can instantiate:

![window.StatsManager](https://s3.amazonaws.com/f.cl.ly/items/3V2F430V1s0L3C431f2N/Image%202014-12-04%20at%202.19.46%20PM.png)

- `stats-manager.require.js` is the CommonJS compliant version. It does not expose a main StatsManager object to `window`, but defines a "require" function, or use the existing one you might have already installed. You can then access to the main object by writing `var StatsManager = require('StatsManager');`

### Web browser
- [stats-manager.js](http://s1.dmcdn.net/IFCUD.js)
- [stats-manager.min.js](http://s1.dmcdn.net/IFCUG.js)
- [stats-manager.require.js](http://s1.dmcdn.net/IFCUS.js)
- [stats-manager.require.min.js](http://s1.dmcdn.net/IFCUa.js)


## Main Objects

### StatsManager

```
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

```

### Plugins

Global plugins constructor options:

- sampling: a **function** returning true or false, defining if the plugin is activated or not

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

- `s_account`: `window.s_account` used by SiteCatalyst
- `pluginUrl`: your `s_code` url

Available methods:


- `setData(data)`: merge data into the global `s` var
- `track(data)`: merge data into the global `s` var and calls `s.t()`
- `trackEvent(data)`: merge data into the global `s` var and calls `s.tl()`
- `reset()`: reset all sProps and eVar of `s`

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
    .filter((data)-> true/false)
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
