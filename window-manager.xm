#!/usr/bin/env xemmai

system = Module("system"
print = system.error.write_line
io = Module("io"
os = Module("os"
math = Module("math"
time = Module("time"
xraft = Module("xraft"
xraftwm = Module("xraftwm"
cairo = Module("cairo"
xraftcairo = Module("xraftcairo"
dbus = Module("dbus"
power = Module("power"

range = @(i, j, callable)
	callable(i for ; i < j; i = i + 1

reverse_each = @(array, callable)
	i = array.size(
	while i > 0
		i = i - 1
		callable(array[i]

first = @(array, predicate)
	n = array.size(
	for i = 0; i < n; i = i + 1
		a = array[i]
		return a if predicate(a)

min = @(x, y) x < y ? x : y
max = @(x, y) x > y ? x : y

floor = @(x) Integer(math.floor(x
ceil = @(x) Integer(math.ceil(x

launch = @(command) @() os.system(command + " &"

create_icon = @(path, width, height)
	s0 = cairo.ImageSurface.create_from_file(path
	try
		w0 = Float(s0.get_width(
		h0 = Float(s0.get_height(
		scale = min(width / w0, height / h0
		pixmap = xraft.Pixmap(ceil(width), ceil(height), true
		s1 = xraftcairo.PixmapSurface(pixmap
		s1.pixmap = pixmap
		context = cairo.Context(s1
		try
			context.rectangle(0.0, 0.0, width, height
			context.set_operator(cairo.Operator.CLEAR
			context.fill(
			context.set_operator(cairo.Operator.OVER
			context.translate((width - w0 * scale) * 0.5, (height - h0 * scale) * 0.5
			context.scale(scale, scale
			context.set_source(s0, 0.0, 0.0
			context.paint(
			s1
		finally
			context.release(
	finally
		s0.release(

create_wall = @(path, width, height)
	s0 = cairo.ImageSurface.create_from_file(path
	try
		w0 = Float(s0.get_width(
		h0 = Float(s0.get_height(
		w1 = Float(width
		h1 = Float(height
		scale = max(w1 / w0, h1 / h0
		s1 = xraft.Pixmap(width, height
		s1.paint(@(g) xraftcairo.draw_on_graphics(g, @(context)
			context.translate((w1 - w0 * scale) * 0.5, (h1 - h0 * scale) * 0.5
			context.scale(scale, scale
			context.set_source(s0, 0.0, 0.0
			context.paint(
		s1
	finally
		s0.release(

Color = Class() :: @
	$__initialize = @(red, green, blue)
		$red = red
		$green = green
		$blue = blue

Colors = Class() :: @
	$__initialize = @(red, green, blue)
		$face = Color(red, green, blue
		$lighters = [
			Color((red * 3.0 + 1.0) / 4.0, (green * 3.0 + 1.0) / 4.0, (blue * 3.0 + 1.0) / 4.0
			Color((red + 1.0) / 2.0, (green + 1.0) / 2.0, (blue + 1.0) / 2.0
			Color((red * 3.0 + 1.0) / 4.0, (green * 3.0 + 1.0) / 4.0, (blue * 3.0 + 1.0) / 4.0
			Color((red * 7.0 + 1.0) / 8.0, (green * 7.0 + 1.0) / 8.0, (blue * 7.0 + 1.0) / 8.0
		$darkers = [
			Color(red * 15.0 / 16.0, green * 15.0 / 16.0, blue * 15.0 / 16.0
			Color(red * 3.0 / 4.0, green * 3.0 / 4.0, blue * 3.0 / 4.0
			Color(red / 2.0, green / 2.0, blue / 2.0
			Color(0.0, 0.0, 0.0

Menu = Class(xraft.Shell) :: @
	$close = @
		$_current = -1
		application = xraft.application(
		break if application.at(i) === $ for i = 0;; i = i + 1
		application.remove(i
	$invalidate_current = @
		h = $item_height(
		y = Float($_current) * h + 4.0
		y0 = floor(y
		y1 = ceil(y + h
		$invalidate(0, y0, $geometry().width(), y1 - y0
	$on_paint = @(g) xraftcairo.draw_on_graphics(g, (@(context)
		root = xraftwm.root(
		colors = root.v_active
		text = root.v_text_active
		extent = $geometry(
		width = Float(extent.width(
		height = Float(extent.height() - 4
		range(0, 4, @(i)
			y = Float(i
			context.set_source_rgb(colors.lighters[i].red, colors.lighters[i].green, colors.lighters[i].blue
			context.rectangle(0.0, y, width, 1.0
			context.fill(
			context.set_source_rgb(colors.darkers[i].red, colors.darkers[i].green, colors.darkers[i].blue
			context.rectangle(0.0, height + y, width, 1.0
			context.fill(
		context.set_scaled_font($_font
		height = $item_height(
		y = 4.0
		range(0, $item_count(), @(i)
			:$item_draw(context, i, 4.0, y, width
			:y = y + height
	)[$]
	$on_button_press = @(modifier, button, x, y)
		if button == xraft.Button.BUTTON1 || button == xraft.Button.BUTTON3
			extent = $geometry(
			$close() if x < 0 || y < 0 || x >= extent.width() || y >= extent.height()
	$on_pointer_enter = @(modifier, x, y, mode, detail) $on_pointer_move(modifier, x, y
	$on_pointer_leave = @(modifier, x, y, mode, detail)
		if $_current != -1
			$invalidate_current(
			$_current = -1
	$on_pointer_move = @(modifier, x, y)
		extent = $geometry(
		h = $item_height(
		y = y - 4
		if x < 0 || y < 0 || x >= extent.width()
			i = -1
		else
			i = Integer(Float(y) / h
			i = -1 if i >= $item_count()
		if i != $_current
			$invalidate_current(
			$_current = i
			$invalidate_current(
	$__initialize = @()
		:$^__initialize[$](
		face = cairo.ToyFontFace("Sans", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL
		matrix = cairo.Matrix(
		matrix.scale(16.0, 16.0
		$_font = cairo.ScaledFont(face, matrix, cairo.Matrix(), cairo.FontOptions()
		face.release(
		$_current = -1
		$show(
	$popup = @(point)
		n = $item_count(
		width = 0.0
		range(0, n, @(i)
			w = :$item_width(i
			:width = w if w > width
		extent = xraft.Extent(8 + ceil(width), 8 + ceil($item_height() * Float(n))
		application = xraft.application(
		screen = application.screen(
		point.x__(screen.width() - extent.width() if point.x() + extent.width() > screen.width()
		point.x__(0 if point.x() < 0
		point.y__(screen.height() - extent.height() if point.y() + extent.height() > screen.height()
		point.y__(0 if point.y() < 0
		$move(xraft.Rectangle(point, extent
		application.add($
		application.pointer_grabber__($

Launcher = Class(Menu) :: @
	Item = Class() :: @
		$__initialize = @(icon, texts, action)
			$v_icon = icon === null ? null : create_icon(icon.__string(), 32.0, 32.0)
			$v_texts = texts
			$v_action = action
		$width = @(font)
			width = 0.0
			$v_texts.each(@(text)
				extents = font.text_extents(text
				:width = extents[2] if extents[2] > width
			36.0 + width

	$item_count = @() $_items.size(
	$item_height = @() $_height
	$item_width = @(i) $_items[i].width($_font
	$item_draw = @(context, i, x, y, width)
		root = xraftwm.root(
		colors = root.v_active
		text = root.v_text_active
		item = $_items[i]
		color = item.v_action !== null && i == $_current ? text : colors.face
		context.set_source_rgb(color.red, color.green, color.blue
		context.rectangle(0.0, y, width, Float($_height)
		context.fill(
		icon = item.v_icon
		if icon !== null
			context.set_source(icon, x + Float(32 - icon.pixmap.width()) / 2.0, y + ($_height - Float(icon.pixmap.height())) / 2.0
			context.paint(
		color = i == $_current ? colors.face : text
		context.set_source_rgb(color.red, color.green, color.blue
		extents = $_font.font_extents(
		h = extents[2]
		x = x + 36.0
		y = y + ($_height - h * Float(item.v_texts.size())) / 2.0 + extents[0]
		item.v_texts.each(@(text)
			context.move_to(x, y
			context.show_text(text
			:y = y + h
	$on_button_release = @(modifier, button, x, y)
		if button == xraft.Button.BUTTON1 || button == xraft.Button.BUTTON3
			if $_current >= 0
				action = $_items[$_current].v_action
				if action !== null
					$close(
					action(
	$__initialize = @
		:$^__initialize[$](
		$_height = max(36.0, $_font.font_extents()[2] * 2.0
		base = io.Path(system.script) / "../window-manager.data"
		$_items = [
			Item(base / "terminal0.png", ["Transparent Terminal", "xrafttt"], launch("xrafttt")
			Item(base / "chromium.gif", ["Chromium"], launch("chromium")
			Item(null, [], null
			Item(base / "xorg.png", ["xterm"], launch("xterm")
			Item(base / "xorg.png", ["xkill"], launch("xkill")
			Item(null, [], null
			Item(null, ["Exit"], xraftwm.root().exit

List = Class(Menu) :: @
	$item_count = @() $_items.size(
	$item_height = @() $_height
	$item_text = @(i)
		item = $_items[i]
		geometry = item.geometry(
		extent = item.extent(
		state = item.visible() ? "Normal" : "Iconic"
		"" + geometry.x() + "@" + geometry.y() + " " + extent.width() + "x" + extent.height() + " " + state
	$item_width = @(i) max($_font.text_extents($_items[i].name())[2], $_font.text_extents($item_text(i))[2]
	$item_draw = @(context, i, x, y, width)
		root = xraftwm.root(
		colors = root.v_active
		text = root.v_text_active
		color = i == $_current ? text : colors.face
		context.set_source_rgb(color.red, color.green, color.blue
		context.rectangle(0.0, y, width, Float($_height)
		context.fill(
		color = i == $_current ? colors.face : text
		context.set_source_rgb(color.red, color.green, color.blue
		extents = $_font.font_extents(
		y = y + $_height / 2.0 + extents[0]
		context.move_to(x, y - extents[2]
		context.show_text($_items[i].name(
		context.move_to(x, y
		context.show_text($item_text(i
	$on_button_release = @(modifier, button, x, y)
		if button == xraft.Button.BUTTON1 || button == xraft.Button.BUTTON3
			if $_current >= 0
				item = $_items[$_current]
				$close(
				xraftwm.root().add(item
				item.shaded__(false
				item.show(
	$__initialize = @
		:$^__initialize[$](
		$_height = max(36.0, $_font.font_extents()[2] * 2.0
	$popup = @(point)
		$_items = xraftwm.root().list_clients(
		:$^popup[$](point

Client = Class(xraftwm.Client) :: @
	Button = Class() :: @
		$__initialize = @(x, y, width, height, polygons, action)
			$v_x = x
			$v_y = y
			$v_width = width
			$v_height = height
			$v_polygons = polygons
			$v_action = action
		$contains = @(x, y) x >= $v_x && x < $v_x + $v_width && y >= $v_y && y < $v_y + $v_height
		$invalidate = @(parent) parent.invalidate($v_x, $v_y, $v_width, $v_height
		$press = @(parent, x, y)
			parent._pressed = $
			$invalidate(parent
		$cursor = @() xraft.application().cursor_arrow(
		$paint = @(context, parent)
			root = parent.parent(
			if $ === parent._pointed
				face = $ === parent._pressed ? root.v_pressed : parent._pressed !== null ? root.v_active.face : root.v_pointed
				text = root.v_text_active
			else if parent === root.active()
				face = root.v_active.face
				text = root.v_text_active
			else
				face = root.v_inactive.face
				text = root.v_text_inactive
			x = Float($v_x
			y = Float($v_y
			w = Float($v_width
			h = Float($v_height
			context.set_source_rgb(face.red, face.green, face.blue
			context.rectangle(x, y, w, h
			context.fill(
			context.set_source_rgb(text.red, text.green, text.blue
			$v_polygons.each(@(polygon)
				context.move_to(x + w * polygon[0][0], y + h * polygon[0][1]
				polygon.each(@(p) context.line_to(x + w * p[0], y + h * p[1]
				context.fill(
	Part = Class() :: @
		$__initialize = @(horizontal, vertical, cursor)
			$v_horizontal = horizontal
			$v_vertical = vertical
			$v_cursor = cursor
		$invalidate = @(parent)
		$press = @(parent, x, y)
			extent = parent.geometry(
			dx = -x
			dx = dx + extent.width() if $v_horizontal == xraftwm.Side.FAR
			dy = -y
			dy = dy + extent.height() if $v_vertical == xraftwm.Side.FAR
			xraftwm.root().resize(parent, $v_horizontal, dx, $v_vertical, dy, $cursor()
		$cursor = @() $v_cursor[xraft.application()](

	v_part_title = Part(xraftwm.Side.BOTH, xraftwm.Side.BOTH, xraft.Application.cursor_arrow
	v_part_content = Part(xraftwm.Side.NONE, xraftwm.Side.NONE, xraft.Application.cursor_x
	v_part_left_top = Part(xraftwm.Side.NEAR, xraftwm.Side.NEAR, xraft.Application.cursor_top_left
	v_part_top = Part(xraftwm.Side.NONE, xraftwm.Side.NEAR, xraft.Application.cursor_top
	v_part_right_top = Part(xraftwm.Side.FAR, xraftwm.Side.NEAR, xraft.Application.cursor_top_right
	v_part_left = Part(xraftwm.Side.NEAR, xraftwm.Side.NONE, xraft.Application.cursor_left
	v_part_right = Part(xraftwm.Side.FAR, xraftwm.Side.NONE, xraft.Application.cursor_right
	v_part_left_bottom = Part(xraftwm.Side.NEAR, xraftwm.Side.FAR, xraft.Application.cursor_bottom_left
	v_part_bottom = Part(xraftwm.Side.NONE, xraftwm.Side.FAR, xraft.Application.cursor_bottom
	v_part_right_bottom = Part(xraftwm.Side.FAR, xraftwm.Side.FAR, xraft.Application.cursor_bottom_right

	$pointed = @(x, y)
		button = first($_buttons, @(button) button.contains(x, y
		return button if button !== null
		extent = $geometry(
		w = extent.width(
		h = extent.height(
		return x < 4 ? v_part_left : x < w - 4 ? v_part_title : v_part_right if $shaded()
		return v_part_title if x >= 4 && x < w - 4 && y >= 4 && y < 20
		return v_part_content if x >= 4 && x < w - 4 && y >= 20 && y < h - 4
		return x < 20 ? v_part_left_top : x < w - 20 ? v_part_top : v_part_right_top if y < 20
		return x < 20 ? v_part_left : v_part_right if y < h - 20
		x < 20 ? v_part_left_bottom : x < w - 20 ? v_part_bottom : v_part_right_bottom
	$maximize = @
		if $_normal === null
			$_normal = $geometry(
			screen = xraft.application().screen(
			borders = $borders(
			$move(xraftwm.Side.NEAR, -borders[0], xraftwm.Side.NEAR, 1 - borders[1]
			$move(xraftwm.Side.FAR, screen.width() + borders[2], xraftwm.Side.FAR, screen.height() + borders[3]
		else
			x = $_normal.x(
			y = $_normal.y(
			$move(xraftwm.Side.NEAR, x, xraftwm.Side.NEAR, y
			$move(xraftwm.Side.FAR, x + $_normal.width(), xraftwm.Side.FAR, y + $_normal.height()
			$_normal = null
	$buttons = @
		$_buttons = [Button(4, 4, 16, 16, [[
			[0.25, 0.5], [0.5, 0.25], [0.75, 0.5], [0.5, 0.75]
		]], $hide
		$_buttons.push(Button(4, 4, 16, 16, [[
			[0.25, 0.25], [0.75, 0.25], [0.75, 0.75], [0.25, 0.75]
		]], $maximize
		if $closable()
			$_buttons.push(Button(4, 4, 16, 16, [[
				[0.125, 0.25], [0.25, 0.125], [0.5, 0.375],
				[0.75, 0.125], [0.875, 0.25], [0.625, 0.5],
				[0.875, 0.75], [0.75, 0.875], [0.5, 0.625],
				[0.25, 0.875], [0.125, 0.75], [0.375, 0.5]
			]], $close
		$_pointed = v_part_title
		$_pressed = null
		$on_move(
	$invalidate_all = @
		extent = $geometry(
		$invalidate(0, 0, extent.width(), extent.height()
	$on_move = @
		x = $geometry().width() - 4
		reverse_each($_buttons, @(button)
			:x = x - button.v_width
			button.v_x = x
		root = $parent(
		return if root === null
		if root._resizing === null
			point = $from_screen(xraft.application().pointer(
			$on_pointer_move(xraft.Modifier.NONE, point.x(), point.y()
		$invalidate_all(
	$on_show = $buttons
	$on_paint = @(g) xraftcairo.draw_on_graphics(g, (@(context)
		root = $parent(
		if $ === root.active()
			colors = root.v_active
			text = root.v_text_active
		else
			colors = root.v_inactive
			text = root.v_text_inactive
		extent = $geometry(
		width = Float(extent.width(
		height = Float(extent.height(
		context.set_source_rgb(colors.face.red, colors.face.green, colors.face.blue
		context.rectangle(0.0, 4.0, width, height - 8.0
		context.fill(
		y0 = height - 4.0
		range(0, 4, @(i)
			y = Float(i
			context.set_source_rgb(colors.lighters[i].red, colors.lighters[i].green, colors.lighters[i].blue
			context.rectangle(0.0, y, width, 1.0
			context.fill(
			context.set_source_rgb(colors.darkers[i].red, colors.darkers[i].green, colors.darkers[i].blue
			context.rectangle(0.0, y0 + y, width, 1.0
			context.fill(
		context.set_scaled_font(root._font
		context.set_source_rgb(text.red, text.green, text.blue
		context.move_to(4.0, 4.0 + root._font.font_extents()[0]
		context.show_text($name(
		$_buttons.each(@(button) button.paint(context, :$
	)[$]
	$on_button_press = @(modifier, button, x, y)
		return if $_pressed !== null || $parent()._resizing !== null
		if button == xraft.Button.BUTTON1
			$_pointed.press($, x, y
		else if button == xraft.Button.BUTTON3
			$shaded__(!$shaded(
	$on_button_release = @(modifier, button, x, y)
		return if $_pressed === null
		$_pressed.v_action() if $_pointed === $_pressed
		$_pressed.invalidate($
		$_pressed = null
		$cursor__($_pointed.cursor(
	$on_pointer_enter = @(modifier, x, y, mode, detail)
		root = $parent(
		return if root._resizing !== null
		root.active__($ if $_pressed === null && detail != xraft.CrossDetail.INNER
		$on_pointer_move(modifier, x, y
	$on_pointer_leave = @(modifier, x, y, mode, detail)
		return if $parent()._resizing !== null
		$on_pointer_move(modifier, x, y
	$on_pointer_move = @(modifier, x, y)
		return if $parent()._resizing !== null
		pointed = $pointed(x, y
		return if pointed === $_pointed
		$_pointed.invalidate($
		$_pointed = pointed
		$_pointed.invalidate($
		$cursor__($_pointed.cursor() if $_pressed === null
	$on_activate = $invalidate_all
	$on_deactivate = $invalidate_all
	$on_name = $invalidate_all
	$on_protocols = @
		$buttons(
		$invalidate_all(
	$__initialize = @
		:$^__initialize[$](
		$_buttons = [
		$_pointed = v_part_title
		$_pressed = null
		$_normal = null
		$borders__([4, 20, 4, 4

Root = Class(xraftwm.Root) :: @
	days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
	pad0 = @(i) i < 10 ? "0" + i : i.__string()
	$invalidate_bar = @
		screen = xraft.application().screen(
		extents = $_font.text_extents("00/00"
		w = ceil(extents[0] + extents[4] + 2.0
		$invalidate(screen.width() - w, 0, w, screen.height()
	$invalidate_clock = @
		$invalidate_bar(
		s = time.decompose(time.now() + Float(time.offset()))[5]
		$_timer.start(Integer((60 - s) * 1000), true
	$draw_center = @(context, x, y, width, text)
		extents = $_font.text_extents(text
		context.move_to(x + (width - extents[0] - extents[4]) * 0.5, y
		context.show_text(text
	$draw = @(context)
		screen = xraft.application().screen(
		extents = $_font.text_extents("00/00"
		w = ceil(extents[0] + extents[4] + 2.0
		h = ceil($_font.font_extents()[2]
		x = screen.width() - w
		y = screen.height() - h * 3 - 2
		context.save(
		context.translate(x + 4, y - h * 5
		$_power.draw(context, w - 8, h * 4
		context.restore(
		context.set_scaled_font($_font
		text = $v_text_active
		context.set_source_rgb(text.red, text.green, text.blue
		t = time.decompose(time.now() + Float(time.offset())
		$draw_center(context, x, y, w, t[0].__string()
		$draw_center(context, x, y + h, w, pad0(t[1]) + "/" + pad0(t[2])
		$draw_center(context, x, y + h * 2, w, days[t[6]]
		$draw_center(context, x, y + h * 3, w, pad0(t[3]) + ":" + pad0(t[4])
	$on_paint0 = @(g) xraftcairo.draw_on_graphics(g, (@(context)
		wall = xraftcairo.PixmapSurface($_wall0
		try
			context.set_source(wall, 0.0, 0.0
			context.paint(
		finally
			wall.release(
		$draw(context
	)[$]
	$on_paint = @(g)
		g.draw(0, 0, $_wall0, 0, 0, $_wall0.width(), $_wall0.height()
		xraftcairo.draw_on_graphics(g, $draw
	$on_button_press = @(modifier, button, x, y)
		return if $_resizing !== null
		if button == xraft.Button.BUTTON1
			$_launcher.popup($to_screen(xraft.Point(x, y
		else if button == xraft.Button.BUTTON3
			$_list.popup($to_screen(xraft.Point(x, y
	$on_button_release = @(modifier, button, x, y)
		return if $_resizing === null || button != xraft.Button.BUTTON1
		$_resizing = null
		application = xraft.application(
		application.pointer_grabber__(null
		$cursor__(application.cursor_x(
	$on_pointer_enter = @(modifier, x, y, mode, detail) $active__(null
	$on_pointer_move = @(modifier, x, y)
		return if $_resizing === null
		client = $_resizing[0]
		horizontal = $_resizing[1]
		x = x + $_resizing[2]
		vertical = $_resizing[3]
		y = y + $_resizing[4]
		screen = xraft.application().screen(
		geometry = client.geometry(
		if horizontal == xraftwm.Side.BOTH
			sw = screen.width(
			gx = geometry.x(
			gw = geometry.width(
			x = 0 if gx >= 0 && x >= -16 && x < 0
			x = sw - gw if gx + gw <= sw && x + gw <= sw + 16 && x + gw > sw
		if vertical == xraftwm.Side.BOTH
			sh = screen.height(
			gy = geometry.y(
			gh = geometry.height(
			y = 0 if gy >= 0 && y >= -16 && y < 0
			y = sh - gh if gy + gh <= sh && y + gh <= sh + 16 && y + gh > sh
		client.move(horizontal, x, vertical, y
	$on_client = Client
	$__initialize = @
		:$^__initialize[$](
		$v_active = Colors(0.0, 3.0 / 16.0, 10.0 / 16.0
		$v_inactive = Colors(2.0 / 16.0, 4.0 / 16.0, 9.0 / 16.0
		$v_text_active = Color(14.0 / 16.0, 14.0 / 16.0, 14.0 / 16.0
		$v_text_inactive = Color(8.0 / 16.0, 8.0 / 16.0, 8.0 / 16.0
		$v_pointed = $v_active.lighters[0]
		$v_pressed = Color(12.0 / 16.0, 8.0 / 16.0, 4.0 / 16.0
		face = cairo.ToyFontFace("Sans", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL
		matrix = cairo.Matrix(
		matrix.scale(16.0, 16.0
		$_font = cairo.ScaledFont(face, matrix, cairo.Matrix(), cairo.FontOptions()
		face.release(
		$_launcher = Launcher(
		$_list = List(
		$_exiting = false
		$_resizing = null
		base = io.Path(system.script) / ".."
		screen = xraft.application().screen(
		width = screen.width(
		height = screen.height(
		$_wall0 = create_wall((base / "wall").__string(), width, height
		$background($_wall0
		$_wall1 = xraft.Pixmap(width, height
		$_wall1.paint(@(g)
			g.draw(0, 0, :$_wall0, 0, 0, width, height
			xraftcairo.draw_on_graphics(g, @(context)
				context.set_source_rgba(0.0, 0.0, 0.0, 0.5
				context.rectangle(0.0, 0.0, Float(width), Float(height)
				context.fill(
		$share_background($_wall1
		$cursor__(xraft.application().cursor_x(
		$_timer = xraft.Timer($invalidate_clock
		$invalidate_clock(
		$_power = power.Indicator($invalidate_bar
	$remove = @(i)
		:$^remove[$](i
		$continue_exit() if $_exiting
	$continue_exit = @
		try
			$list_clients().each(@(x)
				throw x if x.closable()
		catch xraftwm.Client client
			client.close(
			return
		$_exiting = false
		xraft.application().exit(
	$list_clients = @
		items = [
		range(0, $count(), @(i)
			child = :$at(i
			items.unshift(child if child.:.^ === xraftwm.Client
		items
	$exit = @
		$_exiting = true
		$continue_exit(
	$resize = @(client, horizontal, dx, vertical, dy, cursor)
		$_resizing = [client, horizontal, dx, vertical, dy
		xraft.application().pointer_grabber__($
		$cursor__(cursor

xraft.main(system.arguments, @(application) cairo.main(@() dbus.main(@
	try
		Root().run(
	catch Throwable e
		print(e
		e.dump(
