require=(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var EventStream, Eventer, Plugin, Session, Store,
  __slice = Array.prototype.slice;

Eventer = require('./utils/eventer.coffee');

EventStream = require('./utils/eventstream.coffee');

Session = require('./utils/session.coffee');

Store = require('./store.coffee');

Plugin = (function() {
  var _unqueue;

  function Plugin(options) {
    var onModelChange,
      _this = this;
    this.options = options != null ? options : {};
    this._triggerQueue = [];
    this._mixins = {};
    this._eventBus = new Eventer();
    this._data = new Store();
    this.session = new Session();
    this.enabled = true;
    if (this.options.sampling != null) {
      if (!this.setSampling(this.options.sampling)) return;
    }
    onModelChange = function(model, options) {
      if (_this.isReady()) {
        _unqueue.call(_this);
        return _this._data.off('change', onModelChange);
      }
    };
    this._data.on('change', onModelChange);
    this._data.on('change:loaded', function(model, value, options) {
      if (value === true) if (typeof _this.onLoad === "function") _this.onLoad();
    });
    if (typeof this.initialize === "function") this.initialize();
  }

  Plugin.prototype.start = function() {
    this.set('started', true);
    return this;
  };

  _unqueue = function() {
    var _this = this;
    if (this._triggerQueue.length) {
      (function(queue) {
        var queueItem, _i, _len;
        for (_i = 0, _len = queue.length; _i < _len; _i++) {
          queueItem = queue[_i];
          _this.trigger.apply(_this, queueItem);
        }
      })(this._triggerQueue);
    }
    return this;
  };

  Plugin.prototype.isReady = function() {
    return this.get('started') === true && this.get('loaded') === true;
  };

  Plugin.prototype.setSampling = function(isInSample) {
    if ((typeof isInSample === "function" ? isInSample() : void 0) !== true) {
      this.enabled = false;
    }
    return this.enabled;
  };

  Plugin.prototype.get = function(key) {
    return this._data.get(key);
  };

  Plugin.prototype.set = function(key, value, options) {
    return this._data.set(key, value, options);
  };

  Plugin.prototype.remove = function(key) {
    return this._data.unset(key);
  };

  Plugin.prototype.has = function(key) {
    return this._data.get(key) != null;
  };

  Plugin.prototype.trigger = function(e) {
    if (!(e != null) || !this.enabled) return this;
    if (!this.isReady()) {
      this._triggerQueue.push(arguments);
      return this;
    }
    this._eventBus.trigger.apply(this._eventBus, arguments);
    return this;
  };

  Plugin.prototype.listen = function(eventName) {
    var str;
    str = new EventStream(this);
    this._eventBus.on(eventName, str.run.bind(str));
    return str;
  };

  Plugin.prototype.mixin = function(name, fn) {
    this._mixins[name] = fn;
    this[name] = fn.bind(this);
    return this;
  };

  Plugin.prototype.include = function() {
    var args, fn, name;
    name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (fn = this._mixins[name]) return fn.apply(this, args);
    return this;
  };

  Plugin.prototype.loadPlugin = function(pluginUrl) {
    var cs, loaded, s, self;
    self = this;
    cs = document.createElement('script');
    cs.type = 'text/javascript';
    cs.async = true;
    cs.src = pluginUrl;
    loaded = false;
    cs.onload = cs.onreadystatechange = function() {
      if (!loaded && (!this.readyState || this.readyState === 'loaded' || this.readyState === 'complete')) {
        loaded = true;
        if (typeof self.onPluginLoaded === "function") self.onPluginLoaded();
        cs.onload = cs.onreadystatechange = null;
        if (cs.parentNode) cs.parentNode.removeChild(cs);
        self.set('loaded', true);
      }
    };
    cs.onerror = function() {};
    s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(cs, s);
    return this;
  };

  return Plugin;

})();

module.exports = Plugin;

},{"./store.coffee":6,"./utils/eventer.coffee":7,"./utils/eventstream.coffee":8,"./utils/session.coffee":10}],2:[function(require,module,exports){
var ComScorePlugin, Plugin, _consoleColor,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Plugin = require('../plugin.coffee');

_consoleColor = 'color: purple;';

ComScorePlugin = (function(_super) {

  __extends(ComScorePlugin, _super);

  function ComScorePlugin() {
    ComScorePlugin.__super__.constructor.apply(this, arguments);
  }

  ComScorePlugin.prototype._pluginUrl = (ComScorePlugin._is_https ? 'https://sb' : 'http://b') + '.scorecardresearch.com/beacon.js';

  ComScorePlugin.prototype.initialize = function(options) {
    var pluginUrl, _cs;
    if (options == null) options = {};
    pluginUrl = options.pluginUrl;
    if (pluginUrl == null) pluginUrl = this._pluginUrl;
    _cs = window.COMSCORE;
    this.queue = _cs ? false : [];
    if (!_cs) {
      return this.loadPlugin(pluginUrl);
    } else {
      return this.set('loaded', true);
    }
  };

  ComScorePlugin.prototype.isLoaded = function() {
    return window.COMSCORE != null;
  };

  ComScorePlugin.prototype.onLoad = function() {
    this.enabled = this.isLoaded();
    return this;
  };

  ComScorePlugin.prototype.track = function(data) {
    var beacon;
    beacon = window.COMSCORE.beacon;
    return beacon(data);
  };

  return ComScorePlugin;

})(Plugin);

module.exports = ComScorePlugin;

},{"../plugin.coffee":1}],3:[function(require,module,exports){
var GoogleAnalyticsUniversalPlugin, Plugin, _consoleColor,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Plugin = require('../plugin.coffee');

_consoleColor = 'color:red;';

GoogleAnalyticsUniversalPlugin = (function(_super) {

  __extends(GoogleAnalyticsUniversalPlugin, _super);

  function GoogleAnalyticsUniversalPlugin() {
    GoogleAnalyticsUniversalPlugin.__super__.constructor.apply(this, arguments);
  }

  GoogleAnalyticsUniversalPlugin.prototype.initialize = function(options) {
    var account, createParam, domain, _ref;
    _ref = this.options, account = _ref.account, domain = _ref.domain, options = _ref.options;
    if (!(account != null)) return this;
    if (!('ga' in window)) {
      (function(i, s, o, g, r, a, m) {
        i['GoogleAnalyticsObject'] = r;
        i[r] = i[r] || function() {
          (i[r].q = i[r].q || []).push(arguments);
        };
        i[r].l = 1 * new Date();
        a = s.createElement(o);
        m = s.getElementsByTagName(o)[0];
        a.async = 1;
        a.src = g;
        m.parentNode.insertBefore(a, m);
      })(window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga');
    }
    this.set('loaded', true);
    if (options == null) options = {};
    if (domain == null) domain = 'auto';
    createParam = ['create', account, domain, options];
    this.track(createParam);
    return this;
  };

  GoogleAnalyticsUniversalPlugin.prototype.track = function(parameters) {
    var _ga;
    _ga = window.ga;
    _ga.apply(_ga, parameters);
    return this;
  };

  GoogleAnalyticsUniversalPlugin.prototype.trackEvent = function(category, action, opt_label, opt_value, opt_noninteraction) {
    var param;
    param = ['send', 'event', category, action];
    if (opt_label != null) param.push(opt_label);
    if (opt_value != null) param.push(opt_value);
    if (opt_noninteraction != null) {
      param.push({
        nonInteraction: 1
      });
    }
    this.track(param);
    return this;
  };

  GoogleAnalyticsUniversalPlugin.prototype.trackTiming = function(category, variable, time, opt_label, opt_sampleRate) {
    var param;
    if ((0 < time && time < (1000 * 60 * 60))) {
      param = ['send', 'timing', category, variable, time];
      if (opt_label != null) param.push(opt_label);
      if (opt_sampleRate != null) param.push(opt_sampleRate);
      this.track(param);
    }
    return this;
  };

  GoogleAnalyticsUniversalPlugin.prototype.trackPageview = function(options) {
    if (options == null) options = {};
    this.track(['send', 'pageview', options]);
    return this;
  };

  GoogleAnalyticsUniversalPlugin.prototype.trackPageView = GoogleAnalyticsUniversalPlugin.prototype.trackPageview;

  return GoogleAnalyticsUniversalPlugin;

})(Plugin);

module.exports = GoogleAnalyticsUniversalPlugin;

},{"../plugin.coffee":1}],4:[function(require,module,exports){
var Mixins, Plugin, SiteCatalystPlugin, _consoleColor,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Plugin = require('../plugin.coffee');

Mixins = require('../utils/mixins.coffee');

_consoleColor = 'color:blue;';

SiteCatalystPlugin = (function(_super) {

  __extends(SiteCatalystPlugin, _super);

  function SiteCatalystPlugin() {
    SiteCatalystPlugin.__super__.constructor.apply(this, arguments);
  }

  SiteCatalystPlugin.prototype.initialize = function(options) {
    var pluginUrl, _ref;
    this.s = null;
    _ref = this.options, this.s_account = _ref.s_account, pluginUrl = _ref.pluginUrl;
    window.s_account = this.s_account;
    if (!this.isLoaded()) {
      return this.loadPlugin(pluginUrl);
    } else {
      return this.set('loaded', true);
    }
  };

  SiteCatalystPlugin.prototype.isLoaded = function() {
    return window.SiteCatalyst != null;
  };

  SiteCatalystPlugin.prototype.onLoad = function() {
    if (this.isLoaded()) {
      this.s = window.SiteCatalyst.getInstance();
      this.media = this.s.media;
    } else {
      this.enabled = false;
    }
    return this;
  };

  SiteCatalystPlugin.prototype.setRSID = function(rsid) {
    if (!'SiteCatalyst' in window) return;
    this.s.un = rsid;
    return this;
  };

  SiteCatalystPlugin.prototype.setData = function(data) {
    _.assign(this.s, data);
    return this;
  };

  SiteCatalystPlugin.prototype.reset = function() {
    var key, x, _reset;
    _reset = {};
    for (x = 1; x <= 75; x++) {
      key = "prop" + x;
      if (this.s.hasOwnProperty(key)) _reset[key] = '';
    }
    this.setData(_reset);
    return this;
  };

  SiteCatalystPlugin.prototype.track = function(data) {
    if (data != null) this.setData(data);
    this.s.t();
    this.reset();
    return this;
  };

  SiteCatalystPlugin.prototype.trackEvent = function(data, title) {
    if (data != null) this.setData(data);
    this.s.tl(this.s, 'o', title);
    this.reset();
    return this;
  };

  return SiteCatalystPlugin;

})(Plugin);

module.exports = SiteCatalystPlugin;

},{"../plugin.coffee":1,"../utils/mixins.coffee":9}],5:[function(require,module,exports){
var StatsManager,
  __slice = Array.prototype.slice;

StatsManager = (function() {

  function StatsManager(eventList) {
    this.setEvents(eventList);
    this.managers = [];
    this.enabled = true;
  }

  StatsManager.prototype.setEvents = function(eventList) {
    var e, _i, _len;
    this.eventList = eventList;
    if (eventList == null) return;
    for (_i = 0, _len = eventList.length; _i < _len; _i++) {
      e = eventList[_i];
      this[e] = e;
      StatsManager[e] = e;
    }
    return this;
  };

  StatsManager.prototype.register = function(statPluginManager) {
    this.managers.push(statPluginManager);
    return this;
  };

  StatsManager.prototype.start = function() {
    this.map(function(o) {
      return o.start();
    });
    return this;
  };

  StatsManager.prototype.reset = function() {
    this.map(function(o) {
      return o.reset();
    });
    return this;
  };

  StatsManager.prototype.set = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this.map(function(o) {
      return o.set.apply(o, args);
    });
    return this;
  };

  StatsManager.prototype.trigger = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (this.enabled) {
      this.map(function(o) {
        return o.trigger.apply(o, args);
      });
    }
    return this;
  };

  StatsManager.prototype.enable = function() {
    this.enabled = true;
    return this;
  };

  StatsManager.prototype.disable = function(silent) {
    this.enabled = false;
    return this;
  };

  StatsManager.prototype.map = function(cb) {
    var o, _i, _len, _ref;
    _ref = this.managers;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      o = _ref[_i];
      cb(o);
    }
    return this;
  };

  return StatsManager;

})();

module.exports = StatsManager;

},{}],6:[function(require,module,exports){
var Eventer, Store,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Eventer = require('./utils/eventer.coffee');

Store = (function(_super) {

  __extends(Store, _super);

  function Store(data) {
    this.data = data != null ? data : {};
    Store.__super__.constructor.call(this, data);
  }

  Store.prototype.set = function(key, value, silent) {
    var oldValue, _ref;
    if (silent == null) silent = false;
    oldValue = (_ref = this.data[key]) != null ? _ref : null;
    this.data[key] = value;
    if (!silent) {
      return this.emit("change:" + key, {
        oldValue: oldValue,
        newValue: value
      });
    }
  };

  Store.prototype.get = function(key) {
    if (this.data.hasOwnProperty(key)) return this.data[key];
    return null;
  };

  return Store;

})(Eventer);

module.exports = Store;

},{"./utils/eventer.coffee":7}],7:[function(require,module,exports){
var Eventer,
  __slice = Array.prototype.slice;

Eventer = (function() {
  var _on, _removeEvents, _removeNS;

  function Eventer() {
    this._events = {};
  }

  Eventer.prototype.on = function(evt, callback, context, once) {
    var e, list, _i, _len;
    if (once == null) once = false;
    if (!(callback != null)) {
      console.warn('You cannot register to an event without specifying a callback');
      return;
    }
    list = evt.split(' ');
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      e = list[_i];
      _on.call(this, e, callback, context, once);
    }
    return this;
  };

  _on = function(evt, callback, context, once) {
    var _base;
    if (once == null) once = false;
    if ((_base = this._events)[evt] == null) _base[evt] = [];
    return this._events[evt].push({
      name: evt,
      callback: callback,
      context: context || this,
      once: once
    });
  };

  Eventer.prototype.off = function(evt, callback) {
    var ns, _ref;
    if (_ref = evt.match(/^(\.|:)[0-9a-zA-Z_-]+$/), ns = _ref[0], _ref) {
      _removeNS.call(this, evt);
    } else {
      _removeEvents.call(this, evt, callback);
    }
    return this;
  };

  _removeEvents = function(evt, callback) {
    var i, item, len, list;
    if (list = this._events[evt]) {
      i = len = list.length - 1;
      while (i >= 0) {
        item = list[i];
        if (!(callback != null) || item.callback === callback) list.splice(i, 1);
        i--;
      }
    }
    return this;
  };

  _removeNS = function(namespace) {
    var eventList, evt, _i, _len;
    eventList = Object.keys(this._events);
    for (_i = 0, _len = eventList.length; _i < _len; _i++) {
      evt = eventList[_i];
      if (!!~evt.indexOf(namespace)) delete this._events[evt];
    }
    return this;
  };

  Eventer.prototype.once = function(evt, callback, context) {
    this.on(evt, callback, context, true);
    return this;
  };

  Eventer.prototype.trigger = function() {
    var data, evt, item, list, onces, _i, _j, _len, _len2;
    evt = arguments[0], data = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    onces = [];
    if (list = this._events[evt]) {
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        item = list[_i];
        item.callback.apply(item.context, data);
        if (item.once) onces.push(item);
      }
    }
    if (onces.length) {
      for (_j = 0, _len2 = onces.length; _j < _len2; _j++) {
        item = onces[_j];
        list.splice(list.indexOf(item), 1);
      }
    }
    return this;
  };

  Eventer.prototype.reset = function() {
    return this._events.length = 0;
  };

  return Eventer;

})();

Eventer.prototype.emit = Eventer.prototype.trigger;

module.exports = Eventer;

},{}],8:[function(require,module,exports){
var EventStream, EventStreamOperation,
  __slice = Array.prototype.slice;

EventStreamOperation = (function() {

  function EventStreamOperation(name, context, fn) {
    this.name = name;
    this.context = context;
    this.fn = fn;
    this.next = null;
  }

  EventStreamOperation.prototype.run = function() {
    var args, nextArgs, res;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (this.name === 'async') {
      args.push(this.done.bind(this));
      this.fn.apply(this.context, args);
      return;
    }
    res = this.fn.apply(this.context, args);
    nextArgs = typeof res === 'boolean' ? args : res;
    if (res && (this.next != null)) {
      return this.next.run.apply(this.next, nextArgs);
    }
  };

  EventStreamOperation.prototype.done = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (this.next != null) && this.next.run.apply(this.next, args);
  };

  return EventStreamOperation;

})();

EventStream = (function() {

  function EventStream(context) {
    this.context = context;
    this.ops = [];
    this.data = null;
    this.current = null;
  }

  EventStream.prototype.register = function(name, fn) {
    var nextOp,
      _this = this;
    nextOp = new EventStreamOperation(name, this.context, fn);
    (function() {
      var currentOp, currentOpIndex;
      currentOpIndex = _this.ops.length - 1;
      if (currentOpIndex >= 0) {
        currentOp = _this.ops[currentOpIndex];
        return currentOp.next = nextOp;
      }
    })();
    return this.ops.push(nextOp);
  };

  EventStream.prototype.run = function() {
    var args, firstOp, sanitized;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    sanitized = args.filter(function(i) {
      return i != null;
    });
    if (this.ops.length) {
      firstOp = this.ops[0];
      firstOp.run.apply(firstOp, sanitized);
    }
    return this;
  };

  EventStream.prototype.filter = function(operation) {
    var self;
    self = this;
    this.register('filter', function() {
      var args, res;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      try {
        res = operation.apply(self.context, args);
        return res;
      } catch (e) {
        return false;
      }
      return true;
    });
    return this;
  };

  EventStream.prototype.test = function(condition) {
    var self;
    self = this;
    this.register('test', function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return condition.apply(self.context, args);
    });
    return this;
  };

  EventStream.prototype.then = function(callback) {
    this.register('then', callback);
    return this;
  };

  EventStream.prototype.async = function(callback) {
    this.register('async', callback);
    return this;
  };

  return EventStream;

})();

module.exports = EventStream;

},{}],9:[function(require,module,exports){
var Mixins;

Mixins = {
  isObject: function(value) {
    var type;
    type = typeof value;
    return value && (type === 'function' || type === 'object') || false;
  },
  extend: function(object, source, guard) {
    var args, argsIndex, argsLength, index, key, length, props, type;
    args = arguments;
    argsIndex = 0;
    argsLength = args.length;
    type = typeof guard;
    if ((type === "number" || type === "string") && args[3] && args[3][guard] === source) {
      argsLength = 2;
    }
    while (++argsIndex < argsLength) {
      source = args[argsIndex];
      if (isObject(source)) {
        index = -1;
        props = keys(source);
        length = props.length;
        while (++index < length) {
          key = props[index];
          object[key] = source[key];
        }
      }
    }
    return object;
  },
  value: function(input) {
    if (typeof input === 'function') return input();
    return input;
  }
};

module.exports = Mixins;

},{}],10:[function(require,module,exports){
var Session;

Session = (function() {

  function Session() {
    this.history = [];
    this.data = {};
  }

  Session.prototype.log = function() {
    this.history.push(JSON.stringify(arguments));
    return this;
  };

  Session.prototype.hasLog = function(e) {
    var log, _i, _len, _ref;
    _ref = this.history;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      log = _ref[_i];
      if (~log.indexOf('"' + e + '"')) return true;
    }
    return false;
  };

  Session.prototype.save = function(key, value) {
    this.data[key] = value;
    return this;
  };

  Session.prototype.get = function(key) {
    if (key in this.data) {
      return this.data[key];
    } else {
      return null;
    }
  };

  Session.prototype.has = function(key) {
    return !!(key in this.data);
  };

  return Session;

})();

module.exports = Session;

},{}],"StatsManager":[function(require,module,exports){
module.exports = {
  StatsManager: require('./src/stats-manager.coffee'),
  ComScorePlugin: require('./src/plugins/comscore.coffee'),
  GoogleAnalyticsPlugin: require('./src/plugins/googleanalytics.coffee'),
  SiteCatalystPlugin: require('./src/plugins/sitecatalyst.coffee')
};

},{"./src/plugins/comscore.coffee":2,"./src/plugins/googleanalytics.coffee":3,"./src/plugins/sitecatalyst.coffee":4,"./src/stats-manager.coffee":5}]},{},[]);
