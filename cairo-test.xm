system = Module("system");
xraft = Module("xraft");
cairo = Module("cairo");
xraftcairo = Module("xraftcairo");

range = @(i, j, callable) {
	while (i < j) {
		callable(i);
		i = i + 1;
	}
};

tutorial0 = @(context) {
	context.set_source_rgb(0.0, 0.0, 0.0);
	context.move_to(0.0, 0.0);
	context.line_to(1.0, 1.0);
	context.move_to(1.0, 0.0);
	context.line_to(0.0, 1.0);
	context.set_line_width(0.2);
	context.stroke();
	context.rectangle(0.0, 0.0, 0.5, 0.5);
	context.set_source_rgba(1.0, 0.0, 0.0, 0.8);
	context.fill();
	context.rectangle(0.0, 0.5, 0.5, 0.5);
	context.set_source_rgba(0.0, 1.0, 0.0, 0.6);
	context.fill();
	context.rectangle(0.5, 0.0, 0.5, 0.5);
	context.set_source_rgba(0.0, 0.0, 1.0, 0.4);
	context.fill();
};

tutorial1 = @(context) {
	radial = cairo.RadialGradient(0.25, 0.25, 0.1, 0.5, 0.5, 0.5);
	radial.add_color_stop_rgb(0.0, 1.0, 0.8, 0.8);
	radial.add_color_stop_rgb(1.0, 0.9, 0.0, 0.0);
	range(1, 10, @(i) {
		range(1, 10, @(j) {
			context.rectangle(Float(i) / 10.0 - 0.04, Float(j) / 10.0 - 0.04, 0.08, 0.08);
		});
	});
	context.set_source(radial);
	context.fill();
	radial.release();
	linear = cairo.LinearGradient(0.25, 0.35, 0.75, 0.65);
	linear.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.0);
	linear.add_color_stop_rgba(0.25, 0.0, 1.0, 0.0, 0.5);
	linear.add_color_stop_rgba(0.5, 1.0, 1.0, 1.0, 0.0);
	linear.add_color_stop_rgba(0.75, 0.0, 0.0, 1.0, 0.5);
	linear.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.0);
	context.rectangle(0.0, 0.0, 1.0, 1.0);
	context.set_source(linear);
	context.fill();
	linear.release();
};

samples = [
	tutorial0,
	tutorial1
];

draw_with_cairo = @(callable) @(g) xraftcairo.draw_on_graphics(g, callable[$]);

Frame = Class(xraft.Frame) :: @{
	$on_paint = draw_with_cairo(@(context) {
		extent = $geometry();
		context.scale(Float(extent.width()), Float(extent.height()));
		context.rectangle(0.0, 0.0, 1.0, 1.0);
		context.set_source_rgb(1.0, 1.0, 1.0);
		context.fill();
		samples[$i](context);
	});
	$on_key_press = @(modifier, key, ascii) {
		if (key == xraft.Key.Q) $on_close();
		if (key == xraft.Key.SPACE) {
			$i = $i + 1;
			if ($i >= samples.size()) $i = 0;
			extent = $geometry();
			$invalidate(0, 0, extent.width(), extent.height());
		}
	};
	$on_close = @{
		xraft.application().exit();
	};
	$__initialize = @{
		:$^__initialize[$]();
		$i = 0;
	};
};

xraft.main(system.arguments, @(application) {
	cairo.main(@{
		frame = Frame();
		frame.caption__("Cairo Test");
		frame.move(xraft.Rectangle(0, 0, 320, 240));
		application.add(frame);
		frame.show();
		application.run();
	});
});
