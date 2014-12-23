system = Module("system");
math = Module("math");
io = Module("io");
xraft = Module("xraft");
cairo = Module("cairo");
xraftcairo = Module("xraftcairo");

min = @(x, y) x < y ? x : y;

round = @(x) math.floor(x + 0.5);

arc = @(context) {
	xc = 128.0;
	yc = 128.0;
	radius = 100.0;
	angle1 = 45.0 * math.PI / 180.0;
	angle2 = 180.0 * math.PI / 180.0;
	context.set_line_width(10.0);
	context.arc(xc, yc, radius, angle1, angle2);
	context.stroke();
	context.set_source_rgba(1.0, 0.2, 0.2, 0.6);
	context.set_line_width(6.0);
	context.arc(xc, yc, 10.0, 0.0, 2.0 * math.PI);
	context.fill();
	context.arc(xc, yc, radius, angle1, angle1);
	context.line_to(xc, yc);
	context.arc(xc, yc, radius, angle2, angle2);
	context.line_to(xc, yc);
	context.stroke();
};

arc_negative = @(context) {
	xc = 128.0;
	yc = 128.0;
	radius = 100.0;
	angle1 = 45.0 * math.PI / 180.0;
	angle2 = 180.0 * math.PI / 180.0;
	context.set_line_width(10.0);
	context.arc_negative(xc, yc, radius, angle1, angle2);
	context.stroke();
	context.set_source_rgba(1.0, 0.2, 0.2, 0.6);
	context.set_line_width(6.0);
	context.arc(xc, yc, 10.0, 0.0, 2.0 * math.PI);
	context.fill();
	context.arc(xc, yc, radius, angle1, angle1);
	context.line_to(xc, yc);
	context.arc(xc, yc, radius, angle2, angle2);
	context.line_to(xc, yc);
	context.stroke();
};

clip = @(context) {
	context.arc(128.0, 128.0, 76.8, 0.0, 2.0 * math.PI);
	context.clip();
	context.new_path();
	context.rectangle(0.0, 0.0, 256.0, 256.0);
	context.fill();
	context.set_source_rgb(0.0, 1.0, 0.0);
	context.move_to(0.0, 0.0);
	context.line_to(256.0, 256.0);
	context.move_to(256.0, 0.0);
	context.line_to(0.0, 256.0);
	context.set_line_width(10.0);
	context.stroke();
};

clip_image = @(context) {
	context.arc(128.0, 128.0, 76.8, 0.0, 2.0 * math.PI);
	context.clip();
	context.new_path();
	image = cairo.ImageSurface.create_from_png("data/romedalen.png");
	w = Float(image.get_width());
	h = Float(image.get_height());
	context.scale(256.0 / w, 256.0 / h);
	context.set_source(image, 0.0, 0.0);
	context.paint();
	image.release();
};

curve_rectangle = @(context) {
	x0 = 25.6;
	y0 = 25.6;
	rect_width = 204.8;
	rect_height = 204.8;
	radius = 102.4;
	x1 = x0 + rect_width;
	y1 = y0 + rect_height;
	if (rect_width / 2.0 < radius) {
		if (rect_height / 2.0 < radius) {
			context.move_to(x0, (y0 + y1) / 2.0);
			context.curve_to(x0 ,y0, x0, y0, (x0 + x1) / 2.0, y0);
			context.curve_to(x1, y0, x1, y0, x1, (y0 + y1) / 2.0);
			context.curve_to(x1, y1, x1, y1, (x1 + x0) / 2.0, y1);
			context.curve_to(x0, y1, x0, y1, x0, (y0 + y1) / 2.0);
		} else {
			context.move_to(x0, y0 + radius);
			context.curve_to(x0 ,y0, x0, y0, (x0 + x1) / 2.0, y0);
			context.curve_to(x1, y0, x1, y0, x1, y0 + radius);
			context.line_to(x1 , y1 - radius);
			context.curve_to(x1, y1, x1, y1, (x1 + x0) / 2.0, y1);
			context.curve_to(x0, y1, x0, y1, x0, y1 - radius);
		}
	} else {
		if (rect_height / 2.0 < radius) {
			context.move_to(x0, (y0 + y1) / 2.0);
			context.curve_to(x0 , y0, x0 , y0, x0 + radius, y0);
			context.line_to(x1 - radius, y0);
			context.curve_to(x1, y0, x1, y0, x1, (y0 + y1) / 2.0);
			context.curve_to(x1, y1, x1, y1, x1 - radius, y1);
			context.line_to(x0 + radius, y1);
			context.curve_to(x0, y1, x0, y1, x0, (y0 + y1) / 2.0);
		} else {
			context.move_to(x0, y0 + radius);
			context.curve_to(x0 , y0, x0 , y0, x0 + radius, y0);
			context.line_to(x1 - radius, y0);
			context.curve_to(x1, y0, x1, y0, x1, y0 + radius);
			context.line_to(x1 , y1 - radius);
			context.curve_to(x1, y1, x1, y1, x1 - radius, y1);
			context.line_to(x0 + radius, y1);
			context.curve_to(x0, y1, x0, y1, x0, y1 - radius);
		}
	}
	context.close_path();
	context.set_source_rgb(0.5, 0.5, 1.0);
	context.fill_preserve();
	context.set_source_rgba(0.5, 0.0, 0.0, 0.5);
	context.set_line_width(10.0);
	context.stroke();
};

curve_to = @(context) {
	x = 25.6;
	y = 128.0;
	x1 = 102.4;
	y1 = 230.4;
	x2 = 153.6;
	y2 = 25.6;
	x3 = 230.4;
	y3 = 128.0;
	context.move_to(x, y);
	context.curve_to(x1, y1, x2, y2, x3, y3);
	context.set_line_width(10.0);
	context.stroke();
	context.set_source_rgba(1.0 ,0.2 ,0.2 ,0.6);
	context.set_line_width(6.0);
	context.move_to(x, y);
	context.line_to(x1, y1);
	context.move_to(x2, y2);
	context.line_to(x3, y3);
	context.stroke();
};

dash = @(context) {
	dashes = [50.0, 10.0, 10.0, 10.0];
	offset = -50.0;
	context.set_dash(dashes, offset);
	context.set_line_width(10.0);
	context.move_to(128.0, 25.6);
	context.line_to(230.4, 230.4);
	context.rel_line_to(-102.4, 0.0);
	context.curve_to(51.2, 230.4, 51.2, 128.0, 128.0, 128.0);
	context.stroke();
};

fill_and_stroke2 = @(context) {
	context.move_to(128.0, 25.6);
	context.line_to(230.4, 230.4);
	context.rel_line_to(-102.4, 0.0);
	context.curve_to(51.2, 230.4, 51.2, 128.0, 128.0, 128.0);
	context.close_path();
	context.move_to(64.0, 25.6);
	context.rel_line_to(51.2, 51.2);
	context.rel_line_to(-51.2, 51.2);
	context.rel_line_to(-51.2, -51.2);
	context.close_path();
	context.set_line_width(10.0);
	context.set_source_rgb(0.0, 0.0, 1.0);
	context.fill_preserve();
	context.set_source_rgb(0.0, 0.0, 0.0);
	context.stroke();
};

fill_style = @(context) {
	context.set_line_width(6.0);
	context.rectangle(12.0, 12.0, 232.0, 70.0);
	context.new_sub_path();
	context.arc(64.0, 64.0, 40.0, 0.0, 2.0 * math.PI);
	context.new_sub_path();
	context.arc_negative(192.0, 64.0, 40.0, 0.0, -2.0 * math.PI);
	context.set_fill_rule(cairo.FillRule.EVEN_ODD);
	context.set_source_rgb(0.0, 0.7, 0.0);
	context.fill_preserve();
	context.set_source_rgb(0.0, 0.0, 0.0);
	context.stroke();
	context.translate(0.0, 128.0);
	context.rectangle(12.0, 12.0, 232.0, 70.0);
	context.new_sub_path();
	context.arc(64.0, 64.0, 40.0, 0.0, 2.0 * math.PI);
	context.new_sub_path();
	context.arc_negative(192.0, 64.0, 40.0, 0.0, -2.0 * math.PI);
	context.set_fill_rule(cairo.FillRule.WINDING);
	context.set_source_rgb(0.0, 0.0, 0.9);
	context.fill_preserve();
	context.set_source_rgb(0.0, 0.0, 0.0);
	context.stroke();
};

gradient = @(context) {
	pattern = cairo.LinearGradient(0.0, 0.0, 0.0, 256.0);
	pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 0.0, 1.0);
	pattern.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 1.0);
	context.rectangle(0.0, 0.0, 256.0, 256.0);
	context.set_source(pattern);
	context.fill();
	pattern.release();
	pattern = cairo.RadialGradient(115.2, 102.4, 25.6, 102.4, 102.4, 128.0);
	pattern.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 1.0);
	pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 0.0, 1.0);
	context.set_source(pattern);
	context.arc(128.0, 128.0, 76.8, 0.0, 2.0 * math.PI);
	context.fill();
	pattern.release();
};

image = @(context) {
	file = io.File("data/romedalen.png", "rb");
	try {
		image = cairo.ImageSurface.create_from_png_stream(file.read);
	} finally {
		file.close();
	}
	w = Float(image.get_width());
	h = Float(image.get_height());
	context.translate(128.0, 128.0);
	context.rotate(45.0 * math.PI / 180.0);
	context.scale(256.0 / w, 256.0 / h);
	context.translate(-0.5 * w, -0.5 * h);
	context.set_source(image, 0.0, 0.0);
	context.paint();
	image.release();
};

imagepattern = @(context) {
	image = cairo.ImageSurface.create_from_png("data/romedalen.png");
	w = Float(image.get_width());
	h = Float(image.get_height());
	pattern = cairo.SurfacePattern(image);
	pattern.set_extend(cairo.Extend.REPEAT);
	context.translate(128.0, 128.0);
	context.rotate(math.PI / 4.0);
	context.scale(1.0 / math.sqrt(2.0), 1.0 / math.sqrt(2.0));
	context.translate(-128.0, -128.0);
	matrix = cairo.Matrix();
	matrix.scale(w / 256.0 * 5.0, h / 256.0 * 5.0);
	pattern.set_matrix(matrix);
	context.set_source(pattern);
	context.rectangle(0.0, 0.0, 256.0, 256.0);
	context.fill();
	pattern.release();
	image.release();
};

multi_segment_caps = @(context) {
	context.move_to(50.0, 75.0);
	context.line_to(200.0, 75.0);
	context.move_to(50.0, 125.0);
	context.line_to(200.0, 125.0);
	context.move_to(50.0, 175.0);
	context.line_to(200.0, 175.0);
	context.set_line_width(30.0);
	context.set_line_cap(cairo.LineCap.ROUND);
	context.stroke();
};

set_line_cap = @(context) {
	context.set_line_width(30.0);
	context.set_line_cap(cairo.LineCap.BUTT);
	context.move_to(64.0, 50.0);
	context.line_to(64.0, 200.0);
	context.stroke();
	context.set_line_cap(cairo.LineCap.ROUND);
	context.move_to(128.0, 50.0);
	context.line_to(128.0, 200.0);
	context.stroke();
	context.set_line_cap(cairo.LineCap.SQUARE);
	context.move_to(192.0, 50.0);
	context.line_to(192.0, 200.0);
	context.stroke();
	context.set_source_rgb(1.0, 0.2, 0.2);
	context.set_line_width(2.56);
	context.move_to(64.0, 50.0);
	context.line_to(64.0, 200.0);
	context.move_to(128.0, 50.0);
	context.line_to(128.0, 200.0);
	context.move_to(192.0, 50.0);
	context.line_to(192.0, 200.0);
	context.stroke();
};

set_line_join = @(context) {
	context.set_line_width(40.96);
	context.move_to(76.8, 84.48);
	context.rel_line_to(51.2, -51.2);
	context.rel_line_to(51.2, 51.2);
	context.set_line_join(cairo.LineJoin.MITER);
	context.stroke();
	context.move_to(76.8, 161.28);
	context.rel_line_to(51.2, -51.2);
	context.rel_line_to(51.2, 51.2);
	context.set_line_join(cairo.LineJoin.BEVEL);
	context.stroke();
	context.move_to(76.8, 238.08);
	context.rel_line_to(51.2, -51.2);
	context.rel_line_to(51.2, 51.2);
	context.set_line_join(cairo.LineJoin.ROUND);
	context.stroke();
};

text = @(context) {
	context.select_font_face("Sans", cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD);
	context.set_font_size(90.0);
	context.move_to(10.0, 135.0);
	context.show_text("Hello");
	context.move_to(70.0, 165.0);
	context.text_path("void");
	context.set_source_rgb(0.5, 0.5, 1.0);
	context.fill_preserve();
	context.set_source_rgb(0.0, 0.0, 0.0);
	context.set_line_width(2.56);
	context.stroke();
	context.set_source_rgba(1.0, 0.2, 0.2, 0.6);
	context.arc(10.0, 135.0, 5.12, 0.0, 2.0 * math.PI);
	context.close_path();
	context.arc(70.0, 165.0, 5.12, 0.0, 2.0 * math.PI);
	context.fill();
};

text_align_center = @(context) {
	utf8 = "cairo";
	context.select_font_face("Sans", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL);
	context.set_font_size(52.0);
	extents = context.text_extents(utf8);
	x = 128.0 - (extents[2] / 2.0 + extents[0]);
	y = 128.0 - (extents[3] / 2.0 + extents[1]);
	context.move_to(x, y);
	context.show_text(utf8);
	context.set_source_rgba(1.0, 0.2, 0.2, 0.6);
	context.set_line_width(6.0);
	context.arc(x, y, 10.0, 0.0, 2.0 * math.PI);
	context.fill();
	context.move_to(128.0, 0.0);
	context.rel_line_to(0.0, 256.0);
	context.move_to(0.0, 128.0);
	context.rel_line_to(256.0, 0.0);
	context.stroke();
};

text_extents = @(context) {
	utf8 = "cairo";
	context.select_font_face("Sans", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL);
	context.set_font_size(100.0);
	extents = context.text_extents(utf8);
	x = 25.0;
	y = 150.0;
	context.move_to(x, y);
	context.show_text(utf8);
	context.set_source_rgba(1.0, 0.2, 0.2, 0.6);
	context.set_line_width(6.0);
	context.arc(x, y, 10.0, 0.0, 2.0 * math.PI);
	context.fill();
	context.move_to(x, y);
	context.rel_line_to(0.0, -extents[3]);
	context.rel_line_to(extents[2], 0.0);
	context.rel_line_to(extents[0], -extents[1]);
	context.stroke();
};

samples = [
	arc,
	arc_negative,
	clip,
	clip_image,
	curve_rectangle,
	curve_to,
	dash,
	fill_and_stroke2,
	fill_style,
	gradient,
	image,
	imagepattern,
	multi_segment_caps,
	set_line_cap,
	set_line_join,
	text,
	text_align_center,
	text_extents
];

draw_with_cairo = @(callable) @(g) xraftcairo.draw_on_graphics(g, callable[$]);

Frame = Class(xraft.Frame) :: @{
	$on_move = @{
		extent = $geometry();
		$invalidate(0, 0, extent.width(), extent.height());
	};
	$on_paint = draw_with_cairo(@(context) {
		extent = $geometry();
		width0 = height0 = 256.0;
		margin = 8.0;
		width1 = Float(extent.width()) - margin * 2.0;
		height1 = Float(extent.height()) - margin * 2.0;
		scale = min(width1 / width0, height1 / height0);
		context.rectangle(0.0, 0.0, Float(extent.width()), Float(extent.height()));
		context.set_source_rgb(1.0, 1.0, 1.0);
		context.fill();
		sw = round(width0 * scale);
		sh = round(height0 * scale);
		context.translate(round(margin + (width1 - sw) * 0.5), round(margin + (height1 - sh) * 0.5));
		context.rectangle(-0.5, -0.5, sw + 1.0, sh + 1.0);
		context.set_source_rgb(0.95, 0.95, 0.95);
		context.fill_preserve();
		context.set_source_rgb(0.6, 0.6, 0.6);
		context.set_line_width(1.0);
		context.stroke_preserve();
		context.clip();
		context.new_path();
		context.set_source_rgb(0.0, 0.0, 0.0);
		context.scale(scale, scale);
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
