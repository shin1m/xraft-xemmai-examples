math = Module("math"
system = Module("system"
print = system.out.write_line
dbus = Module("dbus"
xraftdbus = Module("xraftdbus"
cairo = Module("cairo"
upower = Module("upower"

$Indicator = Object + @
	$invalidate
	$up
	$line
	$battery
	$online
	$percentage
	$state
	$draw = @(context, width, height)
		w = width - 4.0
		h = height - 8.0
		if $percentage <= 5
			context.set_source_rgb(1.0, 0.5, 0.25
		else
			context.set_source_rgb(1.0, 1.0, 1.0
		context.rectangle(2.0, 6.0, w, h
		context.stroke(
		context.rectangle(2.0 + w * 0.25, 2.0, w * 0.5, 4.0
		y = h * (100.0 - $percentage) / 100.0
		context.rectangle(2.0, 6.0 + y, w, h - y
		u = w * 0.25
		if $state == 1
			context.move_to(width * 0.5, 6.0 + h * 0.25 - u
			context.rel_line_to(-u, u * 2.0
			context.rel_line_to(u * 2.0, 0.0
			context.rel_line_to(-u, -u * 2.0
		else if $state == 2
			context.move_to(width * 0.5, 6.0 + h * 0.25 + u
			context.rel_line_to(-u, -u * 2.0
			context.rel_line_to(u * 2.0, 0.0
			context.rel_line_to(-u, u * 2.0
		else if $state == 4
			context.arc(width * 0.5, 6.0 + h * 0.25, u, 0.0, 2.0 * math.PI
		if $online
			context.rectangle(width * 0.5 + w * (-0.125 - 0.0625 * 0.5), 6.0 + h * 0.75 - u, w * 0.0625, u
			context.rectangle(width * 0.5 + w * (0.125 - 0.0625 * 0.5), 6.0 + h * 0.75 - u, w * 0.0625, u
			context.move_to(width * 0.5, 6.0 + h * 0.75
			context.arc(width * 0.5, 6.0 + h * 0.75, u, 0.0, math.PI
		context.set_fill_rule(cairo.FillRule.EVEN_ODD
		context.fill(
	$refresh = @(message)
		message && print("Properties Changed: " + message.get()
		if $line
			$online = $line.get("Online"
		if $battery
			$percentage = $battery.get("Percentage"
			$state = $battery.get("State"
		$invalidate(
	$reload = @(message)
		if $line
			$line.remove_properties_changed(
			$line = null
		if $battery
			$battery.remove_properties_changed(
			$battery = null
		$up.enumerate_devices().each((@(path)
			device = upower.Device($up.connection, path
			type = device.get("Type"
			if type == 1
				$line = device
			else if type == 2
				$battery = device
		)[$]
		$line && $line.add_properties_changed($refresh
		$battery && $battery.add_properties_changed($refresh
		$refresh(null
	$__initialize = @(invalidate)
		$invalidate = invalidate
		connection = dbus.Connection(dbus.BusType.SYSTEM
		xraftdbus.watch(connection
		$up = upower.UPower(connection
		$up.add_match("DeviceAdded", $reload
		$up.add_match("DeviceRemoved", $reload
		$reload(null
