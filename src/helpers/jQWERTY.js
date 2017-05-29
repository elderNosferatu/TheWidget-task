// Generated by CoffeeScript 1.12.6

/**
 * Stub
 */

(function() {
  var jQWERTY;

  jQWERTY = (function() {
    function jQWERTY() {}

    jQWERTY._STUBS_ = {};

    jQWERTY.post = function(url, success) {
      var stub;
      stub = this._STUBS_[url] = this._STUBS_[url] || new ServerEmulator(url);
      return setTimeout(function() {
        return success(stub.usersAmount);
      }, stub._responseTime);
    };

    return jQWERTY;

  })();

  window.jQWERTY = jQWERTY;

}).call(this);