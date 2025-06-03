system = Module("system"
xraft = Module("xraft"

Hello = xraft.Frame + @
	$foreground
	$background
	$text
	$_count
	$thread
	$on_paint = @(g)
		extent = $geometry(
		g.color($background.pixel(
		g.fill(0, 0, extent.width(), extent.height()
		g.color($foreground.pixel(
		font = xraft.application().font(
		text = $text + ": " + $_count
		w = font.width(text
		h = font.height(
		g.draw((extent.width() - w) / 2, (extent.height() - h) / 2 + font.ascent(), text
		::g = g
	$on_key_press = @(modifier, key, ascii)
		if key == xraft.Key.Q
			$on_close(
		else if key == xraft.Key.T
			$thread && $thread.join(
			$thread = Thread(@
				:$_count = :$_count + 1
				extent = :$geometry(
				:$invalidate(0, 0, extent.width(), extent.height()
		else if key == xraft.Key.P
			$thread && $thread.join(
			application = xraft.application(
			$thread = Thread(@
				application.post(@
					::$_count = ::$_count + 1
					extent = ::$geometry(
					::$invalidate(0, 0, extent.width(), extent.height()
	$on_button_press = @(modifier, button, x, y) if button == xraft.Button.BUTTON3
		$on_close(
	$on_pointer_move = @(modifier, x, y)
		extent = $geometry(
		$invalidate(0, 0, extent.width(), extent.height()
	$on_close = @
		$thread && $thread.join(
		xraft.application().exit(
	$__initialize = @(text)
		xraft.Frame.__initialize[$](
		$foreground = xraft.Color("blue"
		$background = xraft.Color("white"
		$text = text
		$_count = 0

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
