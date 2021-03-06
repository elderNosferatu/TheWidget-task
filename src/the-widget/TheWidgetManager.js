// Generated by CoffeeScript 1.12.6
(function() {
  var ActivityWatchManager, InputManager, RegisterManager, TheWidget, TheWidgetManager, pkg,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  pkg = window.thewidget = window.thewidget || {};

  ActivityWatchManager = pkg.routine.ActivityWatchManager;

  InputManager = pkg.routine.InputManager;

  RegisterManager = pkg.routine.RegisterManager;

  TheWidget = pkg.TheWidget;


  /**
   * TheWidgetManager об"єднує в собі весь фонкціонал пакету `thewidget` для обслуговування єкземплярів віджетів
   * Містить в собі набір базових настройок всiх функціональних компонентів, що дозволяє внести глобальні зміни
   * при інстанціфції менеждера.
   *
   * Параметри:
   *   - holderClass,addInstClass - css-класи для маніпуляцій з плейсходерами
   *
   *   - serverUrl - запит до серверів сайтів, які "вміють" працювати з даними віджетами
   *
   *   - storeKey - місце в `localSorage` для збереження даних реєстру
   *
   *   - instUpdClbkName - ім"я методу віджету, який працює з даними активності
   *
   *   - colors - палітра кольорів для діаграм; підібрана як контраст блідому фону і білому тексту
   *
   *   - defaultSite - адреса дефолтного сайту
   *
   *   - requestDelay - задає темп оновлення даних про активність сайту
   *
   *   - limUsers - умовно порогове значення кількості одночасно активних користувачів сайту;
   *                мотивом для вибору конкретного значення може бути як приблизне навантаження,
   *                яке сервер ще здатний гладко перетерпіти, так і візуальний образ для молитв в стилі "дай мені,
   *                боже, хоч `limUsers` активних фоловерів і я обіцяю бути чемним до кінця року!"
   *
   */

  TheWidgetManager = (function() {
    TheWidgetManager.prototype._cfg = null;

    TheWidgetManager.prototype._cache = null;

    TheWidgetManager.prototype._mgrRegister = null;

    TheWidgetManager.prototype._mgrInput = null;

    TheWidgetManager.prototype._mgrWatch = null;

    function TheWidgetManager(options) {
      var key, value;
      if (options == null) {
        options = null;
      }
      this._clbInstChange = bind(this._clbInstChange, this);
      this._clbInstSuicide = bind(this._clbInstSuicide, this);
      this._clbInput = bind(this._clbInput, this);
      this._parseSrvResp = bind(this._parseSrvResp, this);
      this._addFromReg = bind(this._addFromReg, this);
      this._cfg = {
        colors: ["gray", "navy", "green", "olive", "teal", "blue", "purple", "maroon", "red"],
        holderClass: "place_holder",
        addInstClass: "add_the-widget",
        serverUrl: "the-widget.script",
        storeKey: "TheWidget:register",
        instUpdClbkName: "nextData",
        requestDelay: 1e3,
        limUsers: 100,
        defaultSite: ".",
        knownSites: null
      };
      this._cache = {};
      if (options != null) {
        for (key in options) {
          value = options[key];
          this._cfg[key] = value;
        }
      }
    }

    TheWidgetManager.prototype.run = function() {
      var cfg;
      cfg = this._cfg;
      this._mgrRegister = new RegisterManager(cfg.storeKey);
      this._mgrInput = new InputManager(cfg.holderClass, cfg.addInstClass, this._clbInput);
      this._mgrWatch = new ActivityWatchManager(cfg.requestDelay, cfg.serverUrl, this._parseSrvResp, cfg.instUpdClbkName);
      cfg.knownSites = this._mgrWatch.getKnownSites();
      this._mgrRegister.load();
      return this._mgrRegister.forEach(this._addFromReg);
    };

    TheWidgetManager.prototype._addInstance = function(holderInstance, holderIndex, instanceData) {
      var cfg, opts, theInst;
      if (instanceData == null) {
        instanceData = null;
      }
      cfg = this._cfg;
      opts = instanceData || {};
      opts.site = opts.site || cfg.defaultSite;
      opts.usersLim = opts.usersLim || cfg.limUsers;
      if (opts.color == null) {
        opts.barColor = XMath.arrRnd(cfg.colors);
      }
      theInst = new TheWidget({
        el: holderInstance,
        position: holderIndex,
        knownSites: cfg.knownSites,
        instId: Date.now(),
        suicideCallback: this._clbInstSuicide,
        changeCallback: this._clbInstChange
      });
      theInst.setBarColor(opts.barColor);
      theInst.setUsersLim(opts.usersLim);
      theInst.setSite(opts.site);
      this._cache[holderIndex] = theInst;
      this._mgrInput.setHolderState(holderIndex, true);
      this._mgrWatch.subscribe(theInst, opts.site);
      return this._mgrRegister.set(holderIndex, opts);
    };

    TheWidgetManager.prototype._removeInstance = function(instance, holderInstance, holderIndex) {
      delete this._cache[holderIndex];
      instance.teardown();
      this._mgrInput.setHolderState(holderIndex, false);
      this._mgrWatch.unsubscribe(instance);
      return this._mgrRegister.set(holderIndex, null);
    };

    TheWidgetManager.prototype._addFromReg = function(holderIndex, instanceData) {
      var holder;
      holder = this._mgrInput.getHolder(holderIndex);
      return this._addInstance(holder, holderIndex, instanceData);
    };

    TheWidgetManager.prototype._parseSrvResp = function(data) {
      return parseInt(data) || 0;
    };

    TheWidgetManager.prototype._clbInput = function(holderInstance, holderIndex) {
      this._addInstance(holderInstance, holderIndex);
      return this._mgrRegister.save();
    };

    TheWidgetManager.prototype._clbInstSuicide = function(instance) {
      var holderIndex, holderInstance;
      holderIndex = instance.position;
      holderInstance = this._mgrInput.getHolder(holderIndex);
      this._removeInstance(instance, holderInstance, holderIndex);
      return this._mgrRegister.save();
    };

    TheWidgetManager.prototype._clbInstChange = function(instance) {
      var holderIndex, instanceData;
      holderIndex = instance.position;
      instanceData = this._mgrRegister.get(holderIndex);
      instanceData.site = instance.get("site");
      instanceData.usersLim = instance.get("limUsers");
      this._mgrWatch.subscribe(instance, instanceData.site);
      return this._mgrRegister.save();
    };

    return TheWidgetManager;

  })();

  pkg.TheWidgetManager = TheWidgetManager;

}).call(this);
