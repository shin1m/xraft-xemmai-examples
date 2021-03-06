system = Module("system"
xraft = Module("xraft"
cairo = Module("cairo"
xraftcairo = Module("xraftcairo"

Frame = xraft.Frame + @
	$images
	$pixmap
	$surface
	$timer
	$i
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
		if $i >= $images.size()
			$i = 0
		extent = $geometry(
		$invalidate(0, 0, extent.width(), extent.height()
	$on_paint = @(g) g.draw(0, 0, $pixmap, 0, 0, $pixmap.width(), $pixmap.height()
	$on_key_press = @(modifier, key, ascii)
		if key == xraft.Key.Q
			$on_close(
		else if key == xraft.Key.SPACE
			$timer.stop(
			$step(
	$on_close = @ xraft.application().exit(
	$on_show = @ $step(
	$__initialize = @(path)
		xraft.Frame.__initialize[$](
		$images = cairo.ImageSurface.create_all_from_gif(path
		$pixmap = xraft.Pixmap($images.width, $images.height
		$surface = xraftcairo.PixmapSurface($pixmap
		$timer = xraft.Timer($step
		$i = 0
		$caption__(path
		$move(xraft.Rectangle(0, 0, $images.width, $images.height

xraft.main(system.arguments, @(application) if system.arguments.size() > 0
	cairo.main(@
		frame = Frame(system.arguments[0]
		application.add(frame
		frame.show(
		application.run(
