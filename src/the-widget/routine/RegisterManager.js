// Generated by CoffeeScript 1.12.6
(function() {
  var RegisterManager, pkg;

  pkg = window.thewidget = window.thewidget || {};

  pkg = pkg.routine = pkg.routine || {};


  /**
   Реєстр активних віджетів. Дозволяє, при доступності localStorage, зберігати і завантажуват власну інформацію
   */

  RegisterManager = (function() {
    var _data, _storeKey;

    _storeKey = null;

    _data = null;

    function RegisterManager(_storeKey1) {
      this._storeKey = _storeKey1;
      this._data = {};
    }

    RegisterManager.prototype.load = function() {
      var error, temp;
      try {
        temp = localStorage.getItem(this._storeKey);
        temp = JSON.parse(temp);
      } catch (error1) {
        error = error1;
        null;
      }
      return this._data = temp || {};
    };

    RegisterManager.prototype.save = function() {
      var error, temp;
      try {
        temp = JSON.stringify(this._data);
        return localStorage.setItem(this._storeKey, temp);
      } catch (error1) {
        error = error1;
        return null;
      }
    };

    RegisterManager.prototype.get = function(key) {
      return this._data[key];
    };

    RegisterManager.prototype.set = function(key, value) {
      if (value != null) {
        return this._data[key] = value;
      } else {
        return delete this._data[key];
      }
    };

    RegisterManager.prototype.forEach = function(callback) {
      var idx, key, ref, value;
      if (callback != null) {
        ref = this._data;
        for (key in ref) {
          value = ref[key];
          idx = parseInt(key) || 0;
          callback.call(null, idx, value);
        }
      }
    };

    return RegisterManager;

  })();

  pkg.RegisterManager = RegisterManager;

}).call(this);