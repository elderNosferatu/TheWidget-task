// Generated by CoffeeScript 1.12.6
(function() {
  var ActivityWatcher, pkg,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  pkg = window.thewidget = window.thewidget || {};

  pkg = pkg.routine = pkg.routine || {};

  ActivityWatcher = (function() {
    ActivityWatcher.prototype._url = "";

    ActivityWatcher.prototype._delay = 0;

    ActivityWatcher.prototype._callback = null;

    ActivityWatcher.prototype._askPtr = -1;

    ActivityWatcher.prototype._lastReqTime = 0;

    function ActivityWatcher(_url, _delay, _callback) {
      this._url = _url;
      this._delay = _delay;
      this._callback = _callback;
      this._receive = bind(this._receive, this);
      this._ask = bind(this._ask, this);
    }

    ActivityWatcher.prototype.awake = function() {
      if (this._askPtr === -1) {
        this._askPtr = 0;
        return this._ask();
      }
    };

    ActivityWatcher.prototype.isBusy = function() {
      return this._askPtr === -1;
    };

    ActivityWatcher.prototype.sleep = function() {
      clearTimeout(this._askPtr);
      return this._askPtr = -1;
    };

    ActivityWatcher.prototype._ask = function() {
      this._lastReqTime = Date.now();
      return jQWERTY.post(this._url, this._receive);
    };

    ActivityWatcher.prototype._receive = function(data) {
      var delay, elapsed, now;
      this._callback(data, this);
      now = Date.now();
      elapsed = now - this._lastReqTime;
      delay = (elapsed < this._delay ? this._delay - elapsed : 0);
      return this._askPtr = setTimeout(this._ask, delay);
    };

    return ActivityWatcher;

  })();

  pkg.ActivityWatcher = ActivityWatcher;

}).call(this);
