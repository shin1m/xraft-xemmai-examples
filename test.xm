system = Module("system");
print = system.error.write_line;
xraft = Module("xraft");

Hello = Class(xraft.Frame) :: @{
	$on_paint = @(g) {
		extent = $geometry();
		g.color($background.pixel());
		g.fill(0, 0, extent.width(), extent.height());
		g.color($foreground.pixel());
		font = xraft.application().font();
		w = font.width($text);
		h = font.height();
		g.draw((extent.width() - w) / 2, (extent.height() - h) / 2 + font.ascent(), $text);
	};
	$on_key_press = @(modifier, key, ascii) {
		print(key);
		if (key == xraft.Key.Q) $on_close();
	};
	$on_button_press = @(modifier, button, x, y) {
		print(button);
		if (button == xraft.Button.BUTTON3) $on_close();
	};
	$on_pointer_move = @(modifier, x, y) {
		$cursor = xraft.Point(x, y);
		extent = $geometry();
		$invalidate(0, 0, extent.width(), extent.height());
	};
	$on_close = @{
		xraft.application().exit();
	};
	$__initialize = @(text) {
		:$^__initialize[$]();
		$foreground = xraft.Color("blue");
		$background = xraft.Color("white");
		$text = text;
	};
};

xraft.main(system.arguments, @(application) {
	frame = Hello("Hello, World!!");
	frame.caption__("Hello, World!!");
	frame.move(xraft.Rectangle(0, 0, 320, 240));
	application.add(frame);
	frame.show();
	application.run();
});
