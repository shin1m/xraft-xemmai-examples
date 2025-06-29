system = Module("system"
print = system.out.write_line
libxml = Module("libxml"

ElementReader = libxml.TextReader + @
	$_type
	#$__initialize = @(*arguments)
	#	:$^__initialize[$](*arguments
	$read_next = @ $_type = $read() ? $node_type() : null
	$type = @ $_type
	$move_to_tag = @ while $_type && $_type != libxml.ReaderTypes.ELEMENT && $_type != libxml.ReaderTypes.END_ELEMENT
		$read_next(
	$is_start_element = @(name)
		$move_to_tag(
		$_type == libxml.ReaderTypes.ELEMENT && $local_name() == name
	$check_start_element = @(name) $is_start_element(name) || throw Throwable("must be element: " + name
	$start_element = @(name)
		$check_start_element(name
		b = $is_empty_element(
		$read_next(
		!b
	$end_element = @
		$move_to_tag(
		$_type == libxml.ReaderTypes.END_ELEMENT || throw Throwable("must be end of element."
		$read_next(
	$read_element_text = @
		if $is_empty_element()
			$read_next(
			return ""
		text = ""
		$read_next(
		while $_type != libxml.ReaderTypes.END_ELEMENT
			if $_type == libxml.ReaderTypes.TEXT || $_type == libxml.ReaderTypes.CDATA
				text = text + $value()
				$read_next(
			else if $_type == libxml.ReaderTypes.ELEMENT
				text = text + $read_element_text()
			else
				$read_next(
		$read_next(
		text
	$read_element = @(name)
		$check_start_element(name
		$read_element_text(

Request = Object + @
	$_reader
	$parse_elements = @(elements, x)
		$_reader.read_next(
		$_reader.move_to_tag(
		while $_reader.type() == libxml.ReaderTypes.ELEMENT
			try
				elements[$_reader.local_name()][$](x
			catch Throwable e
				$_reader.read_element_text(
			$_reader.move_to_tag(
		$_reader.read_next(
	image_elements = {
		"url": @(x) x.image_url = $_reader.read_element_text(
	image_elements.share(
	item_elements = {
		"title": @(x) x.title = $_reader.read_element_text(
		"link": @(x) x.link = $_reader.read_element_text(
		"guid": @(x) x.guid = $_reader.read_element_text(
		"date": @(x) x.date = $_reader.read_element_text(
		"pubDate": @(x) x.date = $_reader.read_element_text(
		"pubdate": @(x) x.date = $_reader.read_element_text(
	item_elements.share(
	Item = Object + @
		$title
		$link
		$guid
		$date
	$parse_item = @(x)
		item = Item(
		item.title = item.link = item.guid = item.date = ""
		$parse_elements(item_elements, item
		if item.link == ""
			item.link = item.guid
		x.items['(item.title, item.link)] = '(item.date, x.items.size()
	channel_elements = {
		"title": @(x) x.title = $_reader.read_element_text(
		"date": @(x) x.date = $_reader.read_element_text(
		"updatePeriod": @(x) x.update_period = $_reader.read_element_text(
		"updateFrequency": @(x) x.update_frequency = $_reader.read_element_text(
		"updateBase": @(x) x.update_base = $_reader.read_element_text(
		"ttl": @(x) x.ttl = $_reader.read_element_text(
		"image": @(x) $parse_elements(image_elements, x
		"item": @(x) $parse_item(x
	channel_elements.share(
	rss_elements = {
		"channel": @(x) $parse_elements(channel_elements, x
		"image": @(x) $parse_elements(image_elements, x
		"item": @(x) $parse_item(x
	rss_elements.share(
	entry_elements = {
		"title": @(x) x.title = $_reader.read_element_text(
		"link": @(x)
			x.link = $_reader.get_attribute("href"
			$_reader.read_next(
		"id": @(x) x.guid = $_reader.read_element_text(
		"updated": @(x) x.date = $_reader.read_element_text(
	entry_elements.share(
	$parse_entry = @(x)
		item = Item(
		item.title = item.link = item.guid = item.date = ""
		$parse_elements(entry_elements, item
		if item.link == ""
			item.link = item.guid
		x.items['(item.title, item.link)] = '(item.date, x.items.size()
	feed_elements = {
		"title": @(x) x.title = $_reader.read_element_text(
		"updated": @(x) x.date = $_reader.read_element_text(
		"icon": @(x) x.image_url = $_reader.read_element_text(
		"entry": @(x) $parse_entry(x
	feed_elements.share(
	root_elements = {
		"RDF": @(x) $parse_elements(rss_elements, x
		"rss": @(x) $parse_elements(rss_elements, x
		"feed": @(x) $parse_elements(feed_elements, x
	root_elements.share(
	Channel = Object + @
		$title
		$date
		$update_period
		$update_frequency
		$update_base
		$ttl
		$image_url
		$items
	$__call = @(source)
		x = Channel(
		x.title = ""
		x.date = ""
		x.update_period = ""
		x.update_frequency = ""
		x.update_base = ""
		x.ttl = ""
		x.image_url = ""
		x.items = {
		http = libxml.Http(source
		$_reader = ElementReader(http.read, http.close, source, "", 0
		try
			$parse_elements(root_elements, x
			x
		finally
			$_reader.free(

$ElementReader = ElementReader
$get = @(source) Request()(source

if false
	channel = Request()("https://srad.jp/sradjp.rss"
	print("title: " + channel.title
	print("items: " + channel.items
