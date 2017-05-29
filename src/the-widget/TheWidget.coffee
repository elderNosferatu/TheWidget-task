pkg = window.thewidget = window.thewidget or {}


strTemplate = ->
	"""<div class="the-widget">
	<header>
		<span>Site activity: <a href="" title="{{@this.siteName(site)}}">{{@this.siteName(site)}}</a></span>
	</header>
	<div class="thewidget-btn" on-click="suicide">&times;</div>
	<div class="thewidget-btn" on-click="@this.toggle('options.shown')">+</div>

	{{>chart}}

	<div class="summary">
		<div>lim: {{limUsers}}</div>
		<div>min: {{minUsers}}</div>
		<div>max: {{maxUsers}}</div>
		<div>avg: {{avgUsers}}</div>
	</div>

	{{#if options.shown}}
		{{>options}}
	{{/if}}
</div>"""

strChart = ->
	"""<svg width="{{cfg.easel.width}}" height="{{cfg.easel.height}}">
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

	<rect class="bg"
	      x="0" y="0"
	      width="{{cfg.easel.width}}" height="{{cfg.easel.height}}"/>

	<line x1="1" y1="{{cfg.baseLine}}"
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

strOptions = ->
	"""<div class="options">
	<div class="frame layer-0"></div>
	<div class="frame layer-1"></div>
	<div class="form">
		<p class="caption"><b>TheWidget::options</b></p>
		<hr>
		<p>Site (type or select):</p>
		<input type="text" value="{{options.siteTyped}}" on-click="@this.set('options.siteSelected','')"/>
		<br>
		<select value="{{options.siteSelected}}" on-click="@this.set('options.siteTyped','')">
			<option></option>
			{{#each options.sites}}
				<option value="{{this}}">{{@this.siteName(this)}}</option>
			{{/each}}
		</select>
		<p>Users limit:</p>
		<input type="number" value="{{options.limUsers}}"/>
		<hr>
		<button on-click="@this.toggle('options.shown')">Cancel</button>
		<button on-click="@this.applyOpts()">Apply</button>
	</div>
</div>"""

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
		clsTiny: "tiny"
		indentTinyBottom: 2
		indentLeft: 8

theWidgetInstData = ->
	cfg: theWidgetInstConfig
	options:
		shown: false
		sites: null
		siteTyped: ""
		siteSelected: ""
		limUsers: 0

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





blueprint =
	partials:
		options: strOptions()
		chart: strChart()
	template: strTemplate()
	data: theWidgetInstData

	_CFG_: theWidgetInstConfig
	_barColor: "black"
	_history: null
	_historySum: 0
	_historySteps: 0
	_overwlown: false
	_min: Number.MAX_VALUE
	_max: 0
	_avg: 0
	_lim: 1


	oninit: ->
		@_history = []
		@set "instId", @instId
		hotBgId = @get "hotBgId"
		hotBgId = hotBgId.replace "$param", @instId
		@set "hotBgId", hotBgId
		@set "hotColor", "url('#" + hotBgId + "')"
		@set "drawData", []
		@set "options.sites", @knownSites
		@on {
			suicide: @suicide,
			showOptions: @showOptions
		}

	setUsersLim: (value) ->
		@_lim = value
		@set "limUsers", value
		@set "options.limUsers", value
		@set "drawData", []
		@_refreshData(true)

	setBarColor: (value) ->
		@_barColor = value
		@set "barColor", value
		@_refreshData true

	setSite: (value) ->
		@set "site", value
		@set "options.siteTyped", value
		@set "options.siteSelected", value

	siteName: (rawName) ->
		if rawName isnt "."
			rawName
		else
			@get "cfg.thisSite"

	nextData: (currentAmount) ->
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

	suicide: ->
		if @suicideCallback?
			@suicideCallback @

	applyOpts: ->
		opts = @get "options"
		site = (opts.siteTyped or opts.siteSelected) or "."

		if site and (site isnt @get "site")
			@set "site", site
			if @changeCallback?
				@changeCallback @

		if @_lim isnt opts.limUsers
			@setUsersLim opts.limUsers

		if @changeCallback
			@changeCallback @

		this.toggle('options.shown')

	_refreshData: (isDirty = false) ->
		data = @get "drawData"
		if @_overflown
			data.shift()
		if isDirty
			data.length = 0

		pointer = -1
		limit = @_history.length
		while ++pointer < limit
			amount = @_history[pointer]
			data[pointer] = @_changeData amount, pointer, data[pointer]

		@set "drawData", data


	_changeData: (amount, index, data) ->
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
					cls: (if isTiny then lbl.clsTiny else "")
					y: (if isTiny then barH + lbl.indentTinyBottom else 0.5 * barH)

		data.bar.x = index * (bar.width + bar.spacer)
		data.lbl.x = data.bar.x + lbl.indentLeft

		data





pkg.TheWidget = Ractive.extend(blueprint)
