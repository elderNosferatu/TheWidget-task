// Generated by CoffeeScript 1.12.6

/**
 * Набір костилів
 */

(function() {
  var XMath;

  XMath = (function() {
    function XMath() {}

    XMath.rnd = function(maximum, minimum) {
      var max, min;
      if (minimum == null) {
        minimum = 0;
      }
      min = Math.min(minimum, maximum);
      max = Math.max(minimum, maximum);
      return min + (max - min) * Math.random();
    };

    XMath.intRnd = function(maximum, minimum) {
      if (minimum == null) {
        minimum = 0;
      }
      return Math.round(this.rnd(maximum, minimum));
    };

    XMath.arrRnd = function(array) {
      var idx, result;
      if ((array != null) && (array.length > 0)) {
        idx = this.intRnd(array.length - 1);
        result = array[idx];
      }
      return result;
    };

    return XMath;

  })();

  window.XMath = XMath;

}).call(this);
