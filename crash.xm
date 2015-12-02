system = Module("system"
xraft = Module("xraft"

Hello = Class(xraft.Frame) :: @
	$on_paint = @(g)
		extent = $geometry(
		g.color($background.pixel(
		g.fill(0, 0, extent.width(), extent.height()
		g.color($foreground.pixel(
		font = xraft.application().font(
		text = $text + ": " + $count
		w = font.width(text
		h = font.height(
		g.draw((extent.width() - w) / 2, (extent.height() - h) / 2 + font.ascent(), text
		::g = g
	$on_key_press = @(modifier, key, ascii)
		if key == xraft.Key.Q
			$on_close(
		else if key == xraft.Key.T
			$thread.join() if $thread !== null
			$thread = Thread(@
				:$count = :$count + 1
				extent = :$geometry(
				:$invalidate(0, 0, extent.width(), extent.height()
		else if key == xraft.Key.P
			$thread.join() if $thread !== null
			application = xraft.application(
			$thread = Thread(@
				application.post(@
					::$count = ::$count + 1
					extent = ::$geometry(
					::$invalidate(0, 0, extent.width(), extent.height()
	$on_button_press = @(modifier, button, x, y)
		$on_close() if button == xraft.Button.BUTTON3
	$on_pointer_move = @(modifier, x, y)
		$cursor = xraft.Point(x, y
		extent = $geometry(
		$invalidate(0, 0, extent.width(), extent.height()
	$on_close = @
		$thread.join() if $thread !== null
		xraft.application().exit(
	$__initialize = @(text)
		:$^__initialize[$](
		$foreground = xraft.Color("blue"
		$background = xraft.Color("white"
		$text = text
		$count = 0
		$thread = null

xraft.main(system.arguments, @(application)
	frame = Hello("Hello, World!!"
	frame.caption__("Hello, World!!"
	frame.move(xraft.Rectangle(0, 0, 320, 240
	application.add(frame
	frame.show(
	application.run(
	:application = application
	:frame = frame
try
	g.fill(0, 0, 10, 10
catch Throwable e
	system.error.write_line(e
	e.dump(
catch Object e
	system.error.write_line(e
try
	frame.show(
catch Throwable e
	system.error.write_line(e
	e.dump(
catch Object e
	system.error.write_line(e
try
	application.exit(
catch Throwable e
	system.error.write_line(e
	e.dump(
catch Object e
	system.error.write_line(e
