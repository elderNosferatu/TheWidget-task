pkg = window.thewidget = window.thewidget or {}

###
  Дві наступні функції могли бути просто змінними зі строковими значеннями, але в погоні за читабельністю
  і скролябельністю я вибрав іменно функції, тому що ФОЛДІНГ
###
strTemplate = ->
	"""<div class="b-the-widget">
	<div class="b-the-widget__header">
		<span>Site activity: <a href="" title="{{@this.siteName(site)}}">{{@this.siteName(site)}}</a></span>
	</div>
	<div class="b-the-widget__btn" on-click="suicide">&times;</div>

	{{>chart}}

	<div class="b-the-widget__summary-box">
		<div class="b-the-widget__summary-piece">lim: {{limUsers}}</div>
		<div class="b-the-widget__summary-piece">min: {{minUsers}}</div>
		<div class="b-the-widget__summary-piece">max: {{maxUsers}}</div>
		<div class="b-the-widget__summary-piece">avg: {{avgUsers}}</div>
	</div>

</div>"""

strChart = ->
	"""<svg class='b-widget-chart' width="{{cfg.easel.width}}" height="{{cfg.easel.height}}">
	<defs>
		<linearGradient
				id="{{hotBgId}}"
				gradientUnits="objectBoundingBox"
				spreadMethod="pad"
				x1="0%" x2="0%" y1="0%" y2="100%">
			<stop offset="25%"
			      style="stop-color: {{barColor}};"/>
			<stop offset="100%"
			      style="stop-color: black;"/>
		</linearGradient>
	</defs>

	<rect class="b-widget-chart__bg"
	      x="0" y="0"
	      width="{{cfg.easel.width}}" height="{{cfg.easel.height}}"/>

	<line class="b-widget-chart__base-line"
	      x1="1" y1="{{cfg.baseLine}}"
	      x2="{{cfg.easel.width-1}}" y2="{{cfg.baseLine}}"/>

	<g transform="translate({{0.5*cfg.bar.spacer}}, {{cfg.baseLine}}), scale(1, -1)">
		{{#each drawData:idx}}
			{{#with bar}}
				<rect
					x="{{idx*(cfg.bar.width+cfg.bar.spacer)}}"
					y="{{y}}"
					width="{{w}}"
					height="{{h}}"
					fill="{{bg}}"/>
			{{/with}}
			{{#with lbl}}
				<text
					class="{{cls}}"
					x="0"
					y="0"
					transform="scale(1, -1), rotate(-90), translate({{y}}, {{x}})">{{text}}</text>
			{{/with}}
		{{/each}}
	</g>
</svg>"""


###
  Набір параметрів візуалізацї для віджетів. Навмисне винесений за межі класу, тому що нема
  необхідності плодити єкземпляри цього хешу, адже ці параметри є спільними для всіх віджетів
###
theWidgetInstConfig =
	historySize: 25
	baseLine: 155
	thisSite: "-=[ this site ]=-"
	easel:
		width: 300
		height: 160
	bar:
		hotBgId: "bg_box_hot_$param"
		tinyHeight: 25
		maxHeight: 150
		width: 10
		spacer: 2
	lbl:
		clsNorm: "b-widget-chart__lbl"
		clsTiny: "b-widget-chart__lbl b-widget-chart__lbl_type_tiny"
		indentTinyBottom: 2
		indentLeft: 8

###
  Функція-обгортка необхідна, щоб уберегти хеш options від деребану між віджетами
###
theWidgetInstData = ->
	cfg: theWidgetInstConfig
	barColor: "black"
	hotColor: "black"
	hotBgId: theWidgetInstConfig.bar.hotBgId
	drawData: null
	site: null
	limUsers: 0
	minUsers: 0
	maxUsers: 0
	avgUsers: 0
	instId: 0




###*
 * Шаблон для наслідування єкземпляром класу віджету.
 * У порівнянні з попередньою версією, передбачена можливість настройки віджету після старту.
 * Можна як вибрати порогову кількість відвідувачів, так і перепідписатися на інший сайт.
 * Вищезгадані опції відкриваються новою хнопкою в ПН-СХ куті віджету.
 ###
blueprint =
	partials:
		chart: strChart()
	template: strTemplate()
	data: theWidgetInstData

	_CFG_: theWidgetInstConfig
	_barColor: "black"
	_history: null
	_historySum: 0
	_historySteps: 0
	_overwlown: null
	_requestUrl: null
	_dead: null
	_min: Number.MAX_VALUE
	_max: 0
	_avg: 0
	_lim: 1


	oninit: ->
		method = @_clbResponse
		scope = @
		@_clbResponse = () -> method.apply scope, arguments

		initialData = @initialData
		delete @initialData

		@_history = []
		@_overflown = no
		@_dead = no
		@_requestUrl = initialData.site + "/" + @serverUrl
		@_lim = initialData.limUsers
		@_barColor = initialData.barColor
		hotBgId = @get "hotBgId"
		hotBgId = hotBgId.replace "$param", initialData.instId
		@set "instId", initialData.instId
		@set "hotBgId", hotBgId
		@set "barColor", initialData.barColor
		@set "hotColor", "url('#" + hotBgId + "')"
		@set "limUsers", initialData.limUsers
		@set "site", initialData.site
		@set "drawData", []
		@on { suicide: @suicide }
		@_askData()

	onteardown: ->
		@_dead = yes

	siteName: (rawName) ->
		if rawName isnt "."
			rawName
		else
			@get "cfg.thisSite"

	suicide: ->
		if @suicideCallback?
			@suicideCallback @

	_refreshData: ->
		data = @get "drawData"
		if @_overflown
			data.shift()

		pointer = -1
		limit = @_history.length
		while ++pointer < limit
			amount = @_history[pointer]
			data[pointer] = @_changeInfo amount, pointer, data[pointer]

		@set "drawData", data

	_changeInfo: (amount, index, data) ->
		cfg = @_CFG_
		bar = cfg.bar
		lbl = cfg.lbl

		unless data?
			isHot = amount > @_lim
			barSize = (unless isHot then amount / @_lim else 1)
			barH = barSize * bar.maxHeight
			isTiny = barH < bar.tinyHeight
			data =
				bar:
					bg: (if isHot then @get "hotColor" else @_barColor)
					y: 0
					w: bar.width
					h: barH
				lbl:
					text: amount
					cls: (if isTiny then lbl.clsTiny else lbl.clsNorm)
					y: (if isTiny then barH + lbl.indentTinyBottom else 0.5 * barH)

		data.bar.x = index * (bar.width + bar.spacer)
		data.lbl.x = data.bar.x + lbl.indentLeft

		data

	_askData: ->
		unless @_dead
			$.post @_requestUrl, @_clbResponse

	_clbResponse: (data) ->
		unless @_dead
			@_nextData data
			@_askData()

	_nextData: (currentAmount) ->
		if currentAmount > 0
			@_overflown = @_history.length >= @_CFG_.historySize
			if @_overflown
				@_history.shift()

			@_history.push currentAmount
			@_historySum += currentAmount
			@_historySteps++
			@_avg = Math.round (@_historySum / @_historySteps)
			@_min = Math.min @_min, currentAmount
			@_max = Math.max @_max, currentAmount

			@_refreshData()
			@set "minUsers", @_min
			@set "maxUsers", @_max
			@set "avgUsers", @_avg




pkg.TheWidget = Ractive.extend(blueprint)
