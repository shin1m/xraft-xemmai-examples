system = Module("system");
print = system.out.write_line;
xraft = Module("xraft");
dbus = Module("dbus");
cairo = Module("cairo");
xraftcairo = Module("xraftcairo");
power = Module("power");

Frame = Class(xraft.Frame) :: @{
	$on_paint = @(g) xraftcairo.draw_on_graphics(g, @(context) {
		extent = $geometry();
		width = Float(extent.width());
		height = Float(extent.height());
		context.set_source_rgb(0.0, 0.0, 0.0);
		context.rectangle(0.0, 0.0, width, height);
		context.fill();
		$indicator.draw(context, width, height);
	}[$]);
	$on_key_press = @(modifier, key, ascii) {
		if (key == xraft.Key.Q) $on_close();
	};
	$on_close = @() xraft.application().exit();
	$invalidate_all = @{
		extent = $geometry();
		$invalidate(0, 0, extent.width(), extent.height());
	};
	$__initialize = @{
		:$^__initialize[$]();
		$caption__("Battery");
		$indicator = power.Indicator($invalidate_all);
	};
};

xraft.main(system.arguments, @(application) {
	cairo.main(@{
		dbus.main(@{
			try {
				frame = Frame();
				frame.move(xraft.Rectangle(0, 0, 50, 50));
				application.add(frame);
				frame.show();
				application.run();
			} catch (Throwable e) {
				print(e);
				e.dump();
			}
		});
	});
});
