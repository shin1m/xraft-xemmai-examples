system = Module("system"
print = system.out.write_line
xraft = Module("xraft"
dbus = Module("dbus"
xraftdbus = Module("xraftdbus"
cairo = Module("cairo"
xraftcairo = Module("xraftcairo"
dbusproxy = Module("dbusproxy"

Sender = dbusproxy.Service + @
	$__initialize = @(connection) dbusproxy.Service.__initialize[$](connection, "/foo/Sender", "foo.Sender"
	$emit_message = @(message) $send($signal("Message").string(message

Frame = xraft.Frame + @
	$sender
	$on_paint = @(g) xraftcairo.draw_on_graphics(g, (@(context)
		extent = $geometry(
		width = Float(extent.width(
		height = Float(extent.height(
		context.set_source_rgb(1.0, 1.0, 1.0
		context.rectangle(0.0, 0.0, width, height
		context.fill(
		context.select_font_face("cairo:monospace", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL
		context.set_font_size(24.0
		context.set_source_rgb(0.0, 0.0, 0.0
		extents = context.font_extents(
		context.move_to(0.0, extents[3]
		context.show_text("Type keys"
	)[$]
	$on_key_press = @(modifier, key, ascii) $sender.emit_message(String.from_code(ascii
	$on_close = @ xraft.application().exit(
	$__initialize = @(connection)
		xraft.Frame.__initialize[$](
		$caption__("Sender"
		$sender = Sender(connection

xraft.main(system.arguments, @(application) cairo.main(@ dbus.main(@
	try
		connection = dbus.Connection(dbus.BusType.SESSION
		xraftdbus.watch(connection
		connection.request_name("foo.Sender", 0
		frame = Frame(connection
		frame.move(xraft.Rectangle(0, 0, 200, 26
		application.add(frame
		frame.show(
		application.run(
	catch Throwable e
		print(e
		e.dump(
