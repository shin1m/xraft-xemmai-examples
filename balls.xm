system = Module("system"
math = Module("math"
fabs = math.fabs
sqrt = math.sqrt
xraft = Module("xraft"

Ball = Class() :: @
	$__initialize = @(image, mask, x, y, vx, vy)
		$image = image
		$mask = mask
		$r = Float(image.width()) * 0.5
		$x = Float(x
		$y = Float(y
		$vx = Float(vx
		$vy = Float(vy
	$move = @(extent)
		$x = $x + $vx
		$y = $y + $vy
		if $x < $r
			$vx = fabs($vx
		else if $x > Float(extent.width()) - $r
			$vx = -fabs($vx
		y = Float(extent.height()) - $r - $y
		$vy = y > 0.0 ? $vy + 1.0 : -fabs($vy)
		($vx * $vx + $vy * $vy) * 0.5 + y
	$impact = @(ball)
		dx = ball.x - $x
		dy = ball.y - $y
		l = sqrt(dx * dx + dy * dy
		l >= $r + ball.r && return
		if l > 0.0
			dx = dx / l
			dy = dy / l
		v1 = $vx * dx + $vy * dy
		w1 = $vy * dx - $vx * dy
		v2 = ball.vx * dx + ball.vy * dy
		w2 = ball.vy * dx - ball.vx * dy
		if v2 - v1 < 0.0
			#vv1 = v2
			#vv2 = v1
			vv1 = v2 * 0.999
			vv2 = v1 * 0.999
			$vx = vv1 * dx - w1 * dy
			$vy = w1 * dx + vv1 * dy
			ball.vx = vv2 * dx - w2 * dy
			ball.vy = w2 * dx + vv2 * dy

Balls = Class(xraft.Frame) :: @
	range = @(i, j, callable) for ; i < j; i = i + 1
		callable(i
	$invalidate_all = @
		extent = $geometry(
		$invalidate(0, 0, extent.width(), extent.height()
	$step = @
		balls = $balls
		n = balls.size(
		if n > 0
			range(0, n - 1, @(i)
				range(i + 1, n, @(j) balls[i].impact(balls[j]
		extent = $geometry(
		energy = 0.0
		balls.each(@(ball) :energy = energy + ball.move(extent)
		$energy = energy
		$invalidate_all(
	$remove = @
		$balls.size() > 0 || return
		$balls.shift(
		$invalidate_all(
	$append = @
		cursor = $cursor
		cursor === null && return
		$balls.push(Ball($ball, $mask, cursor.x(), cursor.y(), 0.0, 0.0
		$invalidate_all(
	$on_move = @
		$pixmap.release(
		extent = $geometry(
		$pixmap = xraft.Pixmap(extent.width(), extent.height()
	$paint = @(g)
		extent = $geometry(
		ew = extent.width(
		eh = extent.height(
		#wall = $wall
		#ww = wall.width(
		#wh = wall.height(
		#x = (ew - ww) / 2
		#y = (eh - wh) / 2
		g.color($background.pixel(
		#g.fill(0, 0, ew, y
		#g.fill(0, y, x, wh
		#g.fill(x + ww, y, ew - x - ww, wh
		#g.fill(0, y + wh, ew, eh - y - wh
		#g.draw(x, y, wall, 0, 0, ww, wh
		g.fill(0, 0, ew, eh
		region = xraft.Region(
		region.unite(region, 0, 0, ew / 2 - 8, eh / 2 - 8
		region.unite(region, ew / 2 + 8, 0, ew / 2 - 8, eh / 2 - 8
		region.unite(region, 0, eh / 2 + 8, ew / 2 - 8, eh / 2 - 8
		region.unite(region, ew / 2 + 8, eh / 2 + 8, ew / 2 - 8, eh / 2 - 8
		region.intersect(region, g.region()
		g.clip(region
		$balls.each(@(ball)
			r = ball.r
			image = ball.image
			g.draw(Integer(ball.x - r), Integer(ball.y - r), image, 0, 0, image.width(), image.height(), ball.mask
		g.clip(region
		font = xraft.application().font(
		g.color($foreground.pixel(
		g.font(font
		h = font.height(
		g.draw(0, h, "Number of Balls: " + $balls.size()
		g.draw(0, h * 2, "Kinetic and Potential Energy: " + $energy
		g.draw(0, h * 3, "Double Bufferred: " + $double_bufferred
		cursor = $cursor
		cursor === null && return
		ball = $ball
		r = ball.width() / 2
		g.draw(cursor.x() - r, cursor.y() - r, ball.width(), ball.height()
	$on_paint = @(g)
		if $double_bufferred
			$pixmap.paint($paint
			g.draw(0, 0, $pixmap, 0, 0, $pixmap.width(), $pixmap.height()
		else
			$paint(g
	$on_key_press = @(modifier, key, ascii)
		if key == xraft.Key.SPACE
			$double_bufferred = !$double_bufferred
			$invalidate_all(
		else if key == xraft.Key.Q
			$on_close(
	$on_button_press = @(modifier, button, x, y)
		if button == xraft.Button.BUTTON1
			$append(
		else if button == xraft.Button.BUTTON3
			$balls = [
			$invalidate_all(
	$on_pointer_enter = @(modifier, x, y, mode, detail)
		$cursor = xraft.Point(x, y
		$invalidate_all(
	$on_pointer_leave = @(modifier, x, y, mode, detail)
		$cursor = null
		$invalidate_all(
	$on_pointer_move = @(modifier, x, y)
		$cursor = xraft.Point(x, y
		$invalidate_all(
	$on_close = @ xraft.application().exit(
	$__initialize = @(foreground, background, wall, ball, mask)
		:$^__initialize[$](
		$foreground = foreground
		$background = background
		$wall = wall
		$ball = ball
		$mask = mask
		$balls = [
		$energy = 0.0
		$cursor = null
		$timer0 = xraft.Timer($step
		$timer1 = xraft.Timer($remove
		$double_bufferred = true
		$pixmap = xraft.Pixmap(1, 1
		$timer0.start(30
		$timer1.start(3000

ball_data = @(size, cx, cy, radius)
	data = Bytes(3 * size * size
	for i = 0; i < size; i = i + 1
		for j = 0; j < size; j = j + 1
			dx = Float(j) - cx
			dy = Float(i) - cy
			t = sqrt(dx * dx + dy * dy) / radius
			data[(i * size + j) * 3] = Integer((1.0 - t) * 160.0 + t * 0.0
			data[(i * size + j) * 3 + 1] = Integer((1.0 - t) * 192.0 + t * 0.0
			data[(i * size + j) * 3 + 2] = Integer((1.0 - t) * 255.0 + t * 32.0
	data

mask_data = @(size)
	c = Float(size) * 0.5
	d = c * c
	bpl = (size + 7) / 8
	data = Bytes(bpl * 8 * size
	for i = 0; i < size; i = i + 1
		for j = 0; j < size; j = j + 1
			dx = Float(j) - c
			dy = Float(i) - c
			k = i * bpl + j / 8
			b = 128 >> j % 8
			data[k] = dx * dx + dy * dy > d ? data[k] & ~b : data[k] | b
	data

xraft.main(system.arguments, @(application)
	#base = path.dirname(sys.argv[0])
	#image = Image.open(path.join(base, 'lena.jpg')).convert('RGB')
	#wall = xraft.t_pixmap(image.size[0], image.size[1], image.tostring())
	wall = null
	ball = xraft.Pixmap(32, 32, false, ball_data(32, 12.0, 12.0, 24.0)
	mask = xraft.Bitmap(32, 32, mask_data(32)
	frame = Balls(xraft.Color(0, 0, 255), xraft.Color(255, 255, 255), wall, ball, mask
	frame.caption__("Balls"
	frame.move(xraft.Rectangle(0, 0, 320, 240
	application.add(frame
	frame.show(
	application.run(
