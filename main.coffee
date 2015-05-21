canvas = document.getElementById 'world'
WIDTH = window.innerWidth
HEIGHT = window.innerHeight
frameRate = 0

class Vec2
	constructor: (x,y)->
		@x = x ? 0
		@y = y ? 0

	add: (vec) ->
		@x += vec.x ? 0
		@y += vec.y ? 0
		return @

	multiply: (val) ->
		@x *= val
		@y *= val
		return @

	setAngle: (angle) ->
		length = do @getLength 
		@x = Math.cos(angle) * length
		@y = Math.sin(angle) * length
		return @

	getAngle: ->
		Math.atan2 @y, @x

	setLength: (length) ->
		angle = do @getAngle
		@x = Math.cos(angle) * length
		@y = Math.sin(angle) * length
		return @

	getLength: ->
		Math.sqrt @x * @x + @y * @y



class World
	constructor: (@canvas) ->
		@objects = []
		@WIDTH = @canvas.width = WIDTH
		@HEIGHT = @canvas.height = HEIGHT
		@world = @canvas.getContext '2d'
		@colisions = off
		@ticks = 0

	start: -> do @tick

	tick: ->
		do @update
		do @draw
		window.requestAnimationFrame @tick.bind @

	draw: ->
		@world.clearRect 0, 0, @WIDTH, @HEIGHT
		@world.globalAlpha = 1
		do @showFps
		object.draw @world for object in @objects

	update: ->
		for mainObject, i in @objects when mainObject
			for object, j in @objects when object
				if object isnt mainObject
					mainObject.gravitateTo object
					if @colisions
						if mainObject.r + object.r >= mainObject.distanceTo object
							if mainObject.mass >= object.mass
								mainObject.r += object.r * .7
								mainObject.mass += object.mass
								@objects.splice j, 1
							else
								object.r += mainObject.r * .7
								object.mass += mainObject.mass
								@objects.splice i, 1
		do object.update for object in @objects

	newObject: (newObject) ->
		@objects.push newObject
		return @

	getFps: ->
		if not @lastFpsCall
			@lastFpsCall = Date.now()
			return 0
		difference = (new Date().getTime() - @lastFpsCall) / 1000
		@lastFpsCall = Date.now()
		return Math.floor 1 / difference

	showFps: ->
		fps = do @getFps
		@world.font="30px Verdana";
		@world.fillStyle = "#1BCC26"
		@world.fillText("#{fps} FPS",WIDTH * .9,HEIGHT * .05);

class _Object
	constructor: (params) ->
		@loc = new Vec2 params.x, params.y
		@vel = new Vec2 0, 0
		@vel
			.setLength params.vel
			.setAngle params.dir
		@r = params.r
		@mass = params.mass * 1000000 # mega T
		@G = 6.67 * Math.pow 10, -11

	update: ->
		@loc.add @vel

	draw: (world)->
		if @loc.x - @r > WIDTH
			@loc.x = -@r
		if @loc.x + @r < 0
			@loc.x = WIDTH + @r
		if @loc.y - @r > HEIGHT
			@loc.y = -@r
		if @loc.y + @r < 0
			@loc.y = HEIGHT + @r
		do world.beginPath
		world.fillStyle = "#223"
		world.arc @loc.x,@loc.y,@r,0,2*Math.PI
		do world.fill

	angleTo: (target) ->
		Math.atan2 target.loc.y - @loc.y, target.loc.x - @loc.x

	distanceTo: (target) ->
		dx = target.loc.x - @loc.x 
		dy = target.loc.y - @loc.y
		Math.sqrt dx * dx + dy * dy

	gravitateTo: (target) ->
		gravity = new Vec2
		distance = @distanceTo target
		if distance > .9
			f = @G * (@mass * target.mass) / (distance * distance)
			a = (@mass / f) / 4000000000
		else a = 0
		gravity.setLength a
		gravity.setAngle @angleTo target
		@vel.add gravity

Universe = new World canvas


window.addEventListener 'click', (e) ->
	Universe.newObject new _Object x: e.clientX, y: e.clientY, r: 5, vel: 0, dir: 0, mass: 1




Universe.start()