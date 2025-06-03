#!/usr/bin/env xemmai

system = Module("system"
print = system.out.write_line
os = Module("os"
threading = Module("threading"
math = Module("math"
time = Module("time"
xraft = Module("xraft"
cairo = Module("cairo"
xraftcairo = Module("xraftcairo"
feed = Module("feed"
memory = Module("memory"
libxml = Module("libxml"
mime = Module("mime"

range = @(i, j, callable) for ; i < j; i = i + 1
	callable(i

max = @(x, y) x > y ? x : y
min = @(x, y) x < y ? x : y
abs = @(x) x < 0 ? -x : x
floor = @(x) Integer(math.floor(x
ceil = @(x) Integer(math.ceil(x

retrieve = @(url)
	http = libxml.Http(url
	try
		stream = memory.Memory(
		buffer = Bytes(1024
		while true
			n = http.read(buffer, 0, buffer.size()
			n > 0 || break
			stream.write(buffer, 0, n
		stream
	finally
		http.close(

parse_time = @(text, default = null)
	try
		t = time.parse_rfc2822(text
		time.compose(t) - Float(t[6]
	catch Throwable e
		try
			t = time.parse_xsd(text
			time.compose(t) - Float(t.size() < 7 ? time.offset() : t[6])
		catch Throwable e
			try
				time.compose(time.parse_http(text
			catch Throwable e
				default || time.now(

format_time = @(t)
	o = time.offset(
	time.format_rfc2822(time.decompose(t + Float(o)), o

create_thumbnail = @(image, width, height)
	image || return
	image.rewind(
	try
		s = cairo.ImageSurface.create_from_stream(image.read
	catch Throwable e
		print(e
		e.dump(
		return
	try
		w = Float(s.get_width(
		h = Float(s.get_height(
		scale = min(width / w, height / h
		pixmap = xraft.Pixmap(ceil(width), ceil(height), true
		surface = xraftcairo.PixmapSurface(pixmap
		context = cairo.Context(surface
		try
			context.rectangle(0.0, 0.0, width, height
			context.set_operator(cairo.Operator.CLEAR
			context.fill(
			context.set_operator(cairo.Operator.OVER
			context.translate((width - w * scale) * 0.5, (height - h * scale) * 0.5
			context.scale(scale, scale
			context.set_source(s, 0.0, 0.0
			context.paint(
			'(surface, pixmap
		finally
			context.release(
	finally
		s.release(

Channel = Object + @
	$_url
	$_default_image
	$_date
	$_retrieved
	$_next
	$_image
	$_thumbnail
	$__initialize = @(url, default_image = null)
		$_url = url
		$_default_image = default_image
	$__less = @(x) $_url < x._url
	$initialize = @(width, height)
		$_date = 0.0
		$_retrieved = 0.0
		$_next = 0.0
		$create_thumbnail(width, height
	$create_thumbnail = @(width, height)
		if $_thumbnail
			$_thumbnail[0].release(
			$_thumbnail[1].release(
		$_thumbnail = create_thumbnail($_image, width, height

Worker = Object + @
	$_merge
	$_save
	$_channels
	$_done
	$_mutex
	$_condition
	$_thread
	$update = @(channel)
		print("updating: " + channel._url + " ..."
		c = feed.get(channel._url
		print("got feed."
		date = parse_time(c.date
		channel._date = date
		if c.ttl != ""
			p = Float(c.ttl) * 60.0
			channel._next = date + math.ceil((time.now() - date) / p) * p
		else
			if c.update_period == "hourly"
				p = 3600.0
			else if c.update_period == "daily"
				p = 3600.0 * 24.0
			else if c.update_period == "weekly"
				p = 3600.0 * 24.0 * 7.0
			else if c.update_period == "monthly"
				p = 3600.0 * 24.0 * 30.0
			else if c.update_period == "yearly"
				p = 3600.0 * 24.0 * 365.0
			else
				p = 3600.0
			if c.update_frequency != ""
				p = p / Float(c.update_frequency)
			b = parse_time(c.update_base, date
			channel._next = b + math.ceil((time.now() - b) / p) * p
		url = c.image_url != "" ? c.image_url : channel._default_image
		channel._image = null
		if url
			print("retrieving: " + url + " ..."
			try
				channel._image = retrieve(url
				print("retrieving done."
			catch Throwable e
				print(e
		channel._retrieved = time.now(
		news = c.items
		news.share(
		print("posting ..."
		xraft.application().post((@
			$_mutex.acquire(
			try
				if !$_done
					$_merge(channel, news
					$_condition.signal(
			finally
				$_mutex.release(
		)[$]
		$_condition.wait($_mutex
		print("done next update: " + format_time(channel._next)
	$run = @
		$_mutex.acquire(
		try
			while !$_done
				next = 1000000000.0
				updated = false
				try
					$_channels.each((@(i)
						$_done && throw null
						try
							if i._next < time.now()
								$update(i
								:updated = true
							if i._next < next
								:next = i._next
						catch Throwable e
							print(e
					)[$]
				catch Null e
				$_done && break
				next = next - time.now()
				if next < 300.0
					next = 300.0
				else if next > 3600.0
					next = 3600.0
				next = next + 300.0
				if updated
					xraft.application().post((@
						$_mutex.acquire(
						try
							if !$_done
								$_save(
								$_condition.signal(
						finally
							$_mutex.release(
					)[$]
					$_condition.wait($_mutex
				print("next update: " + format_time(time.now() + next)
				$_condition.wait($_mutex, Integer(next * 1000.0)
		finally
			$_mutex.release(
	$__initialize = @(merge, save, channels)
		$_merge = merge
		$_save = save
		$_channels = channels
		$_done = false
		$_mutex = threading.Mutex(
		$_condition = threading.Condition(
	$start = @ $_thread = Thread($run
	$terminate = @
		$_mutex.acquire(
		try
			$_done = true
			$_condition.signal(
		finally
			$_mutex.release(
		print("waiting for worker ..."
		$_thread.join(
		print("done."

Item = Object + @
	$_channel
	$_key
	$_time
	$_index
	$_retrieved
	$__initialize = @(channel, key, time, index)
		$_channel = channel
		$_key = key
		$_time = parse_time(time, channel._date
		$_index = index
		$_retrieved = channel._retrieved
	pad0 = @(i) i < 10 ? "0" + i : i.__string()
	$date = @
		o = Float(time.offset(
		t = time.decompose($_time + o
		today = time.decompose(time.now() + o
		t[0] == today[0] && t[1] == today[1] && t[2] == today[2] ? pad0(t[3]) + ":" + pad0(t[4]) + ":" + pad0(Integer(t[5])) : pad0(t[0] % 100) + "/" + pad0(t[1]) + "/" + pad0(t[2])

Color = Object + @
	$red
	$green
	$blue
	$__initialize = @(red, green, blue)
		$red = red
		$green = green
		$blue = blue

List = xraft.Frame + @
	$_item_height
	$_image_width
	$_inactive
	$_active
	$_items
	$_sort
	$_position
	$_current
	$_delta
	$_timer
	$_worker
	$_y
	$_pressed
	$_last_tick
	$_last_pointer
	$_moved
	$update_caption = @ $caption__("Feed Reader " + $_worker._channels.size() + " Channels " + $_items.size() + " Items"
	$sort0 = @
		$_items.sort(@(x, y)
			try
				:$_sort.each(@(key)
					a = x.(key[0])
					b = y.(key[0])
					a != b && throw a < b ^ key[1]
				false
			catch Boolean b
				b
		extent = $geometry(
		$invalidate(0, 0, extent.width(), extent.height()
	$sort = @
		$_items.sort(@(x, y)
			sort = :$_sort
			n = sort.size(
			for i = 0; i < n; i = i + 1
				key = sort[i]
				a = x.(key[0])
				b = y.(key[0])
				a != b && return a < b ^ key[1]
			false
		extent = $geometry(
		$invalidate(0, 0, extent.width(), extent.height()
	$merge = @(channel, news)
		news.own(
		channel.create_thumbnail($_image_width, $_item_height
		items = [
		$_items.each(@(i)
			if i._channel === channel
				try
					news.remove(i._key
				catch Throwable e
					return
			items.push(i
		news.each(@(k, v) items.push(Item(channel, k, v[0], v[1]
		$_items = items
		$sort(
		$update_caption(
	load = @(url2channel, items)
		reader = feed.ElementReader(system.script + ".session"
		try
			reader.read_next(
			reader.start_element("session"
			if reader.start_element("channels")
				while reader.is_start_element("channel")
					reader.read_next(
					url = reader.read_element("url"
					channel = Channel(url
					channel._next = parse_time(reader.read_element("next"
					image = [reader.read_element("image")]
					if image[0] != ""
						channel._image = memory.Memory(
						mime.base64_decode(@ image.size() > 0 ? image.shift() : null, channel._image.write
					reader.end_element(
					url2channel[url] = channel
				reader.end_element(
			if reader.start_element("items")
				while reader.is_start_element("item")
					reader.read_next(
					channel = reader.read_element("channel"
					key0 = reader.read_element("key0"
					key1 = reader.read_element("key1"
					t = reader.read_element("time"
					i = Integer(reader.read_element("index"
					item = Item(url2channel[channel], '(key0, key1), t, i
					item._retrieved = parse_time(reader.read_element("retrieved"
					reader.end_element(
					items.push(item
				reader.end_element(
			reader.end_element(
		finally
			reader.free(
	$save = @
		writer = libxml.TextWriter(system.script + ".session", false
		try
			writer.set_indent(true
			writer.start_document("1.0", "utf-8", "yes"
			writer.start_element("session"
			writer.start_element("channels"
			$_worker._channels.each(@(c)
				writer.start_element("channel"
				writer.write_element("url", c._url
				writer.write_element("next", time.format_xsd(time.decompose(c._next), 0, 3)
				writer.start_element("image"
				if c._image
					c._image.rewind(
					mime.base64_encode(c._image.read, @(s) writer.write_string(s), 72
				writer.end_element(
				writer.end_element(
			writer.end_element(
			writer.start_element("items"
			$_items.each(@(i)
				writer.start_element("item"
				writer.write_element("channel", i._channel._url
				writer.write_element("key0", i._key[0]
				writer.write_element("key1", i._key[1]
				writer.write_element("time", time.format_xsd(time.decompose(i._time), 0, 3)
				writer.write_element("index", i._index.__string()
				writer.write_element("retrieved", time.format_xsd(time.decompose(i._retrieved), 0, 3)
				writer.end_element(
			writer.end_element(
			writer.end_element(
			writer.end_document(
		finally
			writer.free(
	$invalidate_row = @
		y = Float($_current) * $_item_height - Float($_position)
		y0 = floor(y
		y1 = ceil(y + $_item_height
		$invalidate(0, y0, $geometry().width(), y1 - y0
	$update_current = @
		if $_pressed || $_delta == 0
			i = floor(Float($_y + $_position) / $_item_height
			if i >= $_items.size()
				i = -1
		else
			i = -1
		i == $_current && return
		$invalidate_row(
		$_current = i
		$invalidate_row(
	$position__ = @(y)
		extent = $geometry(
		bottom = ceil(Float($_items.size()) * $_item_height) - extent.height()
		if y > bottom
			y = bottom
		if y < 0
			y = 0
		y == $_position && return
		$scroll(0, 0, extent.width(), extent.height(), 0, $_position - y
		$_position = y
		$update_current(
	invalid = @(g, context, x, y, width, height)
		point = context.user_to_device(x, y
		x0 = floor(point[0]
		y0 = floor(point[1]
		point = context.user_to_device(x + width, y + height
		x1 = ceil(point[0]
		y1 = ceil(point[1]
		g.invalid(x0, y0, x1 - x0, y1 - y0
	$on_paint = @(g) xraftcairo.draw_on_graphics(g, (@(context)
		extent = $geometry(
		width = Float(extent.width(
		height = Float(extent.height(
		context.select_font_face("cairo:monospace", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL
		context.set_font_size($_item_height - 2.0
		extents = context.text_extents("00:00:00_"
		w = $_image_width
		h = $_item_height
		context.translate(0.0, Float(-$_position)
		bounds = g.bounds(
		y = bounds.y(
		top = context.device_to_user(0.0, Float(y))[1]
		y = y + bounds.height()
		bottom = context.device_to_user(0.0, Float(y))[1]
		i = max(floor(top / h), 0
		j = min(ceil(bottom / h), $_items.size()
		y = Float(i) * h
		range(i, j, (@(i)
			if invalid(g, context, 0.0, y, width, h)
				item = $_items[i]
				colors = i == $_current ? $_active : $_inactive
				context.set_source_rgb(colors[0].red, colors[0].green, colors[0].blue
				context.rectangle(0.0, y, width, h
				context.fill(
				thumbnail = item._channel._thumbnail
				if thumbnail
					context.set_source(thumbnail[0], 0.0, y
					context.paint(
				context.set_source_rgb(colors[1].red, colors[1].green, colors[1].blue
				b = y - extents[1] + 1.0
				context.move_to(w - extents[0], b
				context.show_text(item.date(
				context.move_to(w + extents[2], b
				context.show_text(item._key[0]
			:y = y + h
		)[$]
		y = Float($_items.size()) * h
		if y < height && invalid(g, context, 0.0, y, width, height - y)
			color = $_inactive[0]
			context.set_source_rgb(color.red, color.green, color.blue
			context.rectangle(0.0, y, width, height - y
			context.fill(
	)[$]
	sort_keys = {
		xraft.Key.C: '('('_channel, false), '('_time, true), '('_index, false)
		xraft.Key.R: '('('_retrieved, true), '('_time, true), '('_channel, false), '('_index, false)
		xraft.Key.S: '('('_key, false)
		xraft.Key.T: '('('_time, true), '('_retrieved, true), '('_channel, false), '('_index, false)
	$on_key_press = @(modifier, key, ascii)
		try
			$_sort = sort_keys[key]
		catch Throwable t
			key == xraft.Key.Q && $on_close(
			return
		$sort(
	$on_button_press = @(modifier, button, x, y)
		$_y = y
		$_timer.stop(
		$_delta = 0
		if button == xraft.Button.BUTTON1
			i = floor(Float(y + $_position) / $_item_height
			i < $_items.size() && os.system("navigate " + $_items[i]._key[1] + " &"
		else if button == xraft.Button.BUTTON3
			$_pressed = y + $_position
			$_last_tick = time.tick(
			$_last_pointer = y
			$_moved = false
		else if button == xraft.Button.BUTTON4
			$position__(Integer($_position - $_item_height * 4
		else if button == xraft.Button.BUTTON5
			$position__(Integer($_position + $_item_height * 4
	$delta = @(dt, y) Integer(Float(y - $_last_pointer) * 20.0 / Float(dt)
	$on_button_release = @(modifier, button, x, y)
		$_y = y
		if button == xraft.Button.BUTTON3 && $_pressed
			$_pressed = null
			dt = time.tick() - $_last_tick
			if !$_moved
				$_delta = $delta(max(dt, 5), y
			else if dt > 20
				$_delta = $delta(dt, y
			$_delta != 0 && $_timer.start(20
			$update_current(
	$on_pointer_enter = @(modifier, x, y, mode, detail)
		$_y = y
		$update_current(
	$on_pointer_leave = @(modifier, x, y, mode, detail)
		$_y = y
		if $_current != -1
			$invalidate_row(
			$_current = -1
	$on_pointer_move = @(modifier, x, y)
		$_y = y
		if $_pressed
			$position__($_pressed - y
			tick = time.tick(
			dt = tick - $_last_tick
			if dt > 20
				$_delta = $delta(dt, y
				$_last_tick = tick
				$_last_pointer = y
				$_moved = true
		else
			$update_current(
	$on_close = @
		$_worker.terminate(
		xraft.application().exit(
	$__initialize = @(channels)
		xraft.Frame.__initialize[$](
		$_item_height = 16.0
		$_image_width = 48.0
		$_inactive = [Color(1.0, 1.0, 1.0), Color(0.0, 0.0, 0.0)
		$_active = [Color(0.25, 0.375, 0.75), $_inactive[0]
		olds = {
		items = [
		try
			load(olds, items
		catch Throwable e
			print(e
			e.dump(
		news = [
		channels.each(@(c)
			try
				c0 = olds[c._url]
				c0._default_image = c._default_image
				news.push(c0
			catch Throwable e
				news.push(c
		news.each((@(channel) channel.initialize($_image_width, $_item_height))[$]
		$_items = [
		items.each(@(i) i._channel._next && :$_items.push(i
		$_sort = sort_keys[xraft.Key.R]
		$_position = 0
		$_current = -1
		$_delta = 0
		$_timer = xraft.Timer((@
			if !$_pressed
				position = $_position
				$position__($_position - $_delta
				if $_position == position
					$_delta = 0
			sign = $_delta < 0 ? -1 : 1
			$_delta = sign * max(abs($_delta) - 2, 0)
			if $_delta == 0
				$_timer.stop(
				$update_current(
		)[$]
		news.share(
		$_worker = Worker($merge, $save, news
		$_worker.start(
		$update_caption(

xraft.main(system.arguments, @(application) cairo.main(@
	list = List([
		Channel("https://www.linux.com/feed/"
		Channel("https://srad.jp/sradjp.rss"
		Channel("https://mag.osdn.jp/rss"
		Channel("http://japan.cnet.com/rss/index.rdf", "http://japan.cnet.com/media/c/2010/image/header/cnet_logo.gif"
		Channel("http://www3.asahi.com/rss/index.rdf", "http://www.asahi.com/images08/common/logo.gif"
		Channel("https://tech.nikkeibp.co.jp/rss/index.rdf", "https://pbs.twimg.com/profile_images/1209714081898233861/bq-8wK08_400x400.jpg"
		Channel("https://rss.itmedia.co.jp/rss/2.0/topstory.xml", "https://corp.itmedia.co.jp/common/images/head/logo.gif"
		Channel("https://rss.itmedia.co.jp/rss/2.0/news_bursts.xml", "https://corp.itmedia.co.jp/common/images/head/logo.gif"
		Channel("http://codezine.jp/rss/new/20/index.xml", "http://codezine.jp/static/common/images/logo.gif"
		Channel("https://www.watch.impress.co.jp/data/rss/1.0/ipw/feed.rdf", "http://www.watch.impress.co.jp/header/0804/img/headline_logo.gif"
		Channel("http://feed.rssad.jp/rss/gigazine/rss_atom"
		Channel("http://feeds.gizmodo.jp/rss/gizmodo/index.xml"
		Channel("http://japanese.engadget.com/rss.xml", "http://a1.twimg.com/profile_images/468313888/very_sm_e_normal.png"
		Channel("https://www.infoq.com/feed"
		Channel("http://www.publickey1.jp/atom.xml"
		Channel("https://news.ycombinator.com/rss"
	application.add(list
	list.show(
	application.run(
