system = Module("system"
xraft = Module("xraft"
cairo = Module("cairo"
xraftcairo = Module("xraftcairo"

Frame = Class(xraft.Frame) :: @
	$step = @
		image = $images[$i]
		context = cairo.Context($surface
		try
			if $i == 0
				context.rectangle(0.0, 0.0, Float($images.width), Float($images.height)
				background = $images.background
				context.set_source_rgba(background[0], background[1], background[2], background[3]
				context.fill(
			context.set_source(image, Float(image.left), Float(image.top)
			context.paint(
		finally
			context.release(
		if image.delay > 0
			$timer.start(image.delay * 10, true
		else
			$timer.stop(
		$i = $i + 1
		$i = 0 if $i >= $images.size()
		extent = $geometry(
		$invalidate(0, 0, extent.width(), extent.height()
	$on_paint = @(g) g.draw(0, 0, $pixmap, 0, 0, $pixmap.width(), $pixmap.height()
	$on_key_press = @(modifier, key, ascii)
		$on_close() if key == xraft.Key.Q
		if key == xraft.Key.SPACE
			$timer.stop(
			$step(
	$on_close = @() xraft.application().exit(
	$on_show = @() $step(
	$__initialize = @(path)
		:$^__initialize[$](
		$images = cairo.ImageSurface.create_all_from_gif(path
		$pixmap = xraft.Pixmap($images.width, $images.height
		$surface = xraftcairo.PixmapSurface($pixmap
		$timer = xraft.Timer($step
		$i = 0
		$caption__(path
		$move(xraft.Rectangle(0, 0, $images.width, $images.height

xraft.main(system.arguments, @(application)
	return if system.arguments.size() <= 0
	cairo.main(@
		frame = Frame(system.arguments[0]
		application.add(frame
		frame.show(
		application.run(
