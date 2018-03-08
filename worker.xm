system = Module("system"
print = system.out.write_line
os = Module("os"
threading = Module("threading"
time = Module("time"
xraft = Module("xraft"
cairo = Module("cairo"
xraftcairo = Module("xraftcairo"

format_time = @(t)
	o = time.offset(
	time.format_rfc2822(time.decompose(t + Float(o)), o

Worker = Class() :: @
	$run = @
		$_mutex.acquire(
		try
			while !$_done
				print("updating..."
				message = format_time(time.now(
				xraft.application().post((@
					print("ui acquiring..."
					$_mutex.acquire(
					print("ui acquired."
					try
						if !$_done
							$_message__(message
							print("ui signaling..."
							$_condition.signal(
							print("ui signaled."
					finally
						print("ui releasing..."
						$_mutex.release(
						print("ui released."
				)[$]
				print("sleeping..."
				os.sleep(1000
				print("waiting..."
				$_condition.wait($_mutex
				print("done."
				$_done && break
				$_condition.wait($_mutex, 1000
		finally
			$_mutex.release(
	$__initialize = @(message__)
		$_message__ = message__
		$_done = false
		$_mutex = threading.Mutex(
		$_condition = threading.Condition(
		$share(
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

Frame = Class(xraft.Frame) :: @
	$on_paint = @(g) xraftcairo.draw_on_graphics(g, (@(context)
		extent = $geometry(
		width = Float(extent.width(
		height = Float(extent.height(
		context.select_font_face("cairo:monospace", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL
		context.set_font_size(24.0
		extents = context.text_extents($_message
		context.set_source_rgb(1.0, 1.0, 1.0
		context.rectangle(0.0, 0.0, width, height
		context.fill(
		context.set_source_rgb(0.0, 0.0, 0.0
		context.move_to((width - extents[2]) * 0.5, (height + extents[3]) * 0.5
		context.show_text($_message
	)[$]
	$on_key_press = @(modifier, key, ascii) key == xraft.Key.Q && $on_close(
	$on_close = @
		$_worker.terminate(
		xraft.application().exit(
	$__initialize = @
		:$^__initialize[$](
		$caption__("Worker Test"
		$message__("Starting..."
		$_worker = Worker($message__
		$_worker.start(
	$message__ = @(message)
		$_message = message
		extent = $geometry(
		$invalidate(0, 0, extent.width(), extent.height()

xraft.main(system.arguments, @(application) cairo.main(@
	frame = Frame(
	frame.move(xraft.Rectangle(0, 0, 400, 40
	application.add(frame
	frame.show(
	application.run(
