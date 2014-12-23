#!/usr/bin/env xemmai

system = Module("system");
print = system.error.write_line;
io = Module("io");
math = Module("math");
time = Module("time");
xraft = Module("xraft");
cairo = Module("cairo");
xraftcairo = Module("xraftcairo");
al = Module("al");

range = @(i, j, callable) {
	while (i < j) {
		callable(i);
		i = i + 1;
	}
};

ceil = @(x) Integer(math.ceil(x));

draw_with_cairo = @(callable) @(g) {
	try {
		xraftcairo.draw_on_graphics(g, callable[$]);
	} catch (Throwable e) {
		print(e);
		e.dump();
	}
};

unit = 16.0;

Color = Class() :: @{
	$__initialize = @(red, green, blue) {
		$red = red;
		$green = green;
		$blue = blue;
	};
};

draw_block = @(context, x, y, color) {
	context.rectangle(x * unit, y * unit, unit, unit);
	context.set_source_rgb(color.red, color.green, color.blue);
	context.fill();
	context.set_line_width(2.0);
	x0 = x * unit + 1.0;
	x1 = x0 + unit - 2.0;
	y0 = y * unit + 1.0;
	y1 = y0 + unit - 2.0;
	context.move_to(x1, y0);
	context.line_to(x0, y0);
	context.line_to(x0, y1);
	context.set_source_rgb((color.red + 1.0) * 0.5, (color.green + 1.0) * 0.5, (color.blue + 1.0) * 0.5);
	context.stroke();
	context.move_to(x0, y1);
	context.line_to(x1, y1);
	context.line_to(x1, y0);
	context.set_source_rgb(color.red * 0.5, color.green * 0.5, color.blue * 0.5);
	context.stroke();
};

Tetrimino = Class() :: @{
	$__initialize = @(blocks, color, left_offsets, right_offsets) {
		$_blocks = blocks;
		$_color = color;
		$_left_offsets = left_offsets;
		$_right_offsets = right_offsets;
	};
	$draw = @(context, direction, x, y) {
		$_blocks[direction].each(@(b) {
			draw_block(context, x + b[0], y + b[1], $_color);
		}[$]);
	};
	check = @(row) {
		for (i = 1; i < 11; i = i + 1) if (row[i] === null) return false;
		true;
	};
	$fix = @(rows, direction, x, y) {
		fixeds = [];
		$_blocks[direction].each(@(b) {
			i = b[1];
			rows[y + i][x + b[0]] = $_color;
			while (fixeds.size() <= i) fixeds.push(false);
			fixeds[i] = true;
		}[$]);
		filleds = [];
		range(0, fixeds.size(), @(i) {
			if (!fixeds[i]) return;
			j = y + i;
			if (check(rows[j])) filleds.push(j);
		});
		filleds;
	};
	$conflicts = @(rows, direction, x, y) {
		bs = $_blocks[direction];
		n = bs.size();
		for (i = 0; i < n; i = i + 1) {
			b = bs[i];
			if (rows[y + b[1]][x + b[0]] !== null) return true;
		}
		false;
	};
	$try_rotate = @(rows, direction, x, y, offsets) {
		if (!$conflicts(rows, direction, x, y)) return '(x, y);
		os = offsets[direction];
		n = os.size();
		for (i = 0; i < n; i = i + 1) {
			o = os[i];
			x0 = x + o[0];
			y0 = y + o[1];
			if (!$conflicts(rows, direction, x0, y0)) {
				while (y0 < y) {
					y1 = y0 + 1;
					if ($conflicts(rows, direction, x0, y1)) break;
					y0 = y1;
				}
				return '(x0, y0);
			}
		}
	};
	$try_rotate_left = @(rows, direction, x, y) $try_rotate(rows, direction, x, y, $_left_offsets);
	$try_rotate_right = @(rows, direction, x, y) $try_rotate(rows, direction, x, y, $_right_offsets);
	$ghost = @(rows, direction, x, y) {
		while (true) {
			y0 = y + 1;
			if ($conflicts(rows, direction, x, y0)) break;
			y = y0;
		}
		y;
	};
	$draw_ghost = @(context, direction, x, y) {
		$_blocks[direction].each(@(b) context.rectangle((x + b[0]) * unit + 0.5, (y + b[1]) * unit + 0.5, unit - 1.0, unit - 1.0));
		context.set_line_width(1.0);
		context.set_source_rgb($_color.red, $_color.green, $_color.blue);
		context.stroke();
	};
	$draw_hard_drop = @(context, direction, x, y0, y1, alpha) {
		pattern = cairo.LinearGradient(x * unit, y0 * unit, x * unit, y1 * unit);
		try {
			pattern.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.0);
			pattern.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, alpha);
			dy = y1 - y0;
			$_blocks[direction].each(@(b) context.rectangle((x + b[0]) * unit, (y0 + b[1]) * unit, unit, dy * unit));
			context.set_source(pattern);
			context.fill();
		} finally {
			pattern.release();
		}
	};
};

tetriminos = '(
	Tetrimino('(
		'('(0, 2), '(1, 2), '(2, 2), '(3, 2)),
		'('(1, 0), '(1, 1), '(1, 2), '(1, 3)),
		'('(0, 1), '(1, 1), '(2, 1), '(3, 1)),
		'('(2, 0), '(2, 1), '(2, 2), '(2, 3))
	), Color(0.0, 1.0, 1.0), '(
		'('(-2, 0), '(1, 0), '(1, -2), '(-2, 1)),
		'('(-1, 0), '(2, 0), '(-1, -2), '(2, 1)),
		'('(2, 0), '(-1, 0), '(2, -1), '(-1, 2)),
		'('(-2, 0), '(1, 0), '(-2, -1), '(1, 1))
	), '(
		'('(2, 0), '(-1, 0), '(-1, -2), '(2, 1)),
		'('(2, 0), '(-1, 0), '(2, -1), '(-1, 1)),
		'('(-2, 0), '(1, 0), '(-2, -1), '(1, 2)),
		'('(-2, 0), '(1, 0), '(1, -2), '(-2, 1))
	)),
	Tetrimino('(
		'('(1, 1), '(2, 1), '(1, 2), '(2, 2)),
		'('(1, 1), '(2, 1), '(1, 2), '(2, 2)),
		'('(1, 1), '(2, 1), '(1, 2), '(2, 2)),
		'('(1, 1), '(2, 1), '(1, 2), '(2, 2))
	), Color(1.0, 1.0, 0.0), '(
		'(),
		'(),
		'(),
		'()
	), '(
		'(),
		'(),
		'(),
		'()
	)),
	Tetrimino('(
		'('(1, 1), '(2, 1), '(0, 2), '(1, 2)),
		'('(1, 1), '(1, 2), '(2, 2), '(2, 3)),
		'('(1, 2), '(2, 2), '(0, 3), '(1, 3)),
		'('(0, 1), '(0, 2), '(1, 2), '(1, 3))
	), Color(0.0, 1.0, 0.0), '(
		'('(1, 0), '(1, 1), '(0, -2), '(1, -2)),
		'('(-1, 0), '(-1, -1), '(0, 2), '(-1, 2)),
		'('(-1, 0), '(-1, 1), '(0, -2), '(-1, -2)),
		'('(1, 0), '(1, -1), '(0, 2), '(1, 2))
	), '(
		'('(-1, 0), '(-1, 1), '(0, -2), '(-1, -2)),
		'('(-1, 0), '(-1, -1), '(0, 2), '(-1, 2)),
		'('(1, 0), '(1, 1), '(0, -2), '(1, -2)),
		'('(1, 0), '(1, -1), '(0, 2), '(1, 2))
	)),
	Tetrimino('(
		'('(0, 1), '(1, 1), '(1, 2), '(2, 2)),
		'('(2, 1), '(1, 2), '(2, 2), '(1, 3)),
		'('(0, 2), '(1, 2), '(1, 3), '(2, 3)),
		'('(1, 1), '(0, 2), '(1, 2), '(0, 3))
	), Color(1.0, 0.0, 0.0), '(
		'('(1, 0), '(1, 1), '(0, -2), '(1, -2)),
		'('(-1, 0), '(-1, -1), '(0, 2), '(-1, 2)),
		'('(-1, 0), '(-1, 1), '(0, -2), '(-1, -2)),
		'('(1, 0), '(1, -1), '(0, 2), '(1, 2))
	), '(
		'('(-1, 0), '(-1, 1), '(0, -2), '(-1, -2)),
		'('(-1, 0), '(-1, -1), '(0, 2), '(-1, 2)),
		'('(1, 0), '(1, 1), '(0, -2), '(1, -2)),
		'('(1, 0), '(1, -1), '(0, 2), '(1, 2))
	)),
	Tetrimino('(
		'('(0, 1), '(0, 2), '(1, 2), '(2, 2)),
		'('(1, 1), '(2, 1), '(1, 2), '(1, 3)),
		'('(0, 2), '(1, 2), '(2, 2), '(2, 3)),
		'('(1, 1), '(1, 2), '(0, 3), '(1, 3))
	), Color(0.0, 0.0, 1.0), '(
		'('(1, 0), '(1, 1), '(0, -2), '(1, -2)),
		'('(-1, 0), '(-1, -1), '(0, 2), '(-1, 2)),
		'('(-1, 0), '(-1, 1), '(0, -2), '(-1, -2)),
		'('(1, 0), '(1, -1), '(0, 2), '(1, 2))
	), '(
		'('(-1, 0), '(-1, 1), '(0, -2), '(-1, -2)),
		'('(-1, 0), '(-1, -1), '(0, 2), '(-1, 2)),
		'('(1, 0), '(1, 1), '(0, -2), '(1, -2)),
		'('(1, 0), '(1, -1), '(0, 2), '(1, 2))
	)),
	Tetrimino('(
		'('(2, 1), '(0, 2), '(1, 2), '(2, 2)),
		'('(1, 1), '(1, 2), '(1, 3), '(2, 3)),
		'('(0, 2), '(1, 2), '(2, 2), '(0, 3)),
		'('(0, 1), '(1, 1), '(1, 2), '(1, 3))
	), Color(1.0, 0.5, 0.0), '(
		'('(1, 0), '(1, 1), '(0, -2), '(1, -2)),
		'('(-1, 0), '(-1, -1), '(0, 2), '(-1, 2)),
		'('(-1, 0), '(-1, 1), '(0, -2), '(-1, -2)),
		'('(1, 0), '(1, -1), '(0, 2), '(1, 2))
	), '(
		'('(-1, 0), '(-1, 1), '(0, -2), '(-1, -2)),
		'('(-1, 0), '(-1, -1), '(0, 2), '(-1, 2)),
		'('(1, 0), '(1, 1), '(0, -2), '(1, -2)),
		'('(1, 0), '(1, -1), '(0, 2), '(1, 2))
	)),
	Tetrimino('(
		'('(1, 1), '(0, 2), '(1, 2), '(2, 2)),
		'('(1, 1), '(1, 2), '(2, 2), '(1, 3)),
		'('(0, 2), '(1, 2), '(2, 2), '(1, 3)),
		'('(1, 1), '(0, 2), '(1, 2), '(1, 3))
	), Color(1.0, 0.0, 1.0), '(
		'('(1, 0), '(1, 1), '(0, -2), '(1, -2)),
		'('(-1, 0), '(-1, -1), '(0, 2), '(-1, 2)),
		'('(-1, 0), '(-1, 1), '(0, -2), '(-1, -2)),
		'('(1, 0), '(1, -1), '(0, 2), '(1, 2))
	), '(
		'('(-1, 0), '(-1, 1), '(0, -2), '(-1, -2)),
		'('(-1, 0), '(-1, -1), '(0, 2), '(-1, 2)),
		'('(1, 0), '(1, 1), '(0, -2), '(1, -2)),
		'('(1, 0), '(1, -1), '(0, 2), '(1, 2))
	))
);

Stage = Class(xraft.Widget) :: @{
	$width = ceil(21 * unit);
	$height = ceil(22 * unit);

	$invalidate_all = @{
		extent = $geometry();
		$invalidate(0, 0, extent.width(), extent.height());
	};
	$on_move = @{
		$invalidate_all();
	};
	$draw = @{
		context = cairo.Context($_surface);
		try {
			context.save();
			context.rectangle(0.0, 0.0, $width, $height);
			context.set_source_rgb(1.0, 1.0, 1.0);
			context.fill();
			context.arc(3 * unit, 3 * unit, 2 * unit, 0.0, 2.0 * math.PI);
			context.rectangle(5.5 * unit, unit, 10 * unit, 20 * unit);
			context.rectangle(16 * unit, unit, 4 * unit, 12 * unit);
			context.set_line_width(unit);
			context.set_line_join(cairo.LineJoin.ROUND);
			context.set_source_rgb(0.125, 0.25, 0.5);
			context.stroke_preserve();
			context.set_source_rgb(0.75, 0.75, 0.75);
			context.fill();
			context.restore();
			context.save();
			context.translate(4.5 * unit, -3 * unit);
			if ($_hard_drop !== null) $_hard_drop.draw_hard_drop(context, $_hard_drop_direction, $_hard_drop_x, $_hard_drop_y0, $_hard_drop_y1, Float($_ticks_to_fade_hard_drop) / $_speed_to_fade_hard_drop);
			range(3, 24, @(i) {
				row = $_rows[i];
				range(1, 11, @(j) {
					block = row[j];
					if (block !== null) draw_block(context, j, i, block);
				});
			}[$]);
			if ($_filleds.size() > 0) {
				context.set_source_rgba(1.0, 1.0, 1.0, Float($_speed_to_clear - $_ticks_to_wait) / $_speed_to_clear);
				$_filleds.each(@(i) {
					context.rectangle(unit, i * unit, 10 * unit, unit);
					context.fill();
				});
			}
			if ($_tetrimino !== null) {
				$_tetrimino.draw_ghost(context, $_direction, $_x, $_ghost);
				$_tetrimino.draw(context, $_direction, $_x, $_y);
			}
			context.restore();
			if ($_held !== null) {
				context.save();
				context.translate(unit, (1.0 - 4.0 * $_ticks_to_hold / $_speed_to_hold) * unit);
				$_held.draw(context, 0, 0, 0);
				context.restore();
			}
			context.translate(16 * unit, (1.0 + 4.0 * $_ticks_to_next / $_speed_to_next) * unit);
			range(0, 3, @(i) {
				tetriminos[$_nexts[i]].draw(context, 0, 0, i * 4);
			}[$]);
		} finally {
			context.release();
		}
		$invalidate_all();
	};
	$on_paint = draw_with_cairo(@(context) {
		context.set_source($_surface, 0.0, 0.0);
		context.paint();
	});
	$load_sound = @(name) {
		path = (io.Path(system.script) / "../tetris.sounds" / name).__string();
		source = $_context.create_source();
		source.set_buffer($_context.get_device().create_buffer_from_file(path));
		source;
	};
	$__initialize = @(context) {
		:$^__initialize[$]();
		$_gray = Color(0.5, 0.5, 0.5);
		$_pixmap = xraft.Pixmap($width, $height);
		$_surface = xraftcairo.PixmapSurface($_pixmap);
		$_timer = xraft.Timer($tick);
		$_context = context;
		$_sound_bgm = $load_sound("bgm.wav");
		$_sound_bgm.setb(al.LOOPING, true);
		$_sound_over = $load_sound("over.wav");
		$_sound_impact = $load_sound("impact.wav");
		$_sound_clear = $load_sound("clear.wav");
		$_sound_hold = $load_sound("hold.wav");
		$on_clear = null;
		$reset();
	};
	next7 = @{
		ns = [0, 1, 2, 3, 4, 5, 6];
		range(0, 7, @(i) {
			j = Integer(math.modf(time.now())[0] * 24.0 * 60.0 * 60.0) % 7;
			a = ns[i];
			ns[i] = ns[j];
			ns[j] = a;
		});
		ns;
	};
	$reset = @{
		$_sound_bgm.stop();
		$_timer.stop();
		gray = $_gray;
		guard = [gray, gray, gray, gray, gray, gray, gray, gray, gray, gray, gray, gray];
		$_rows = [guard, guard];
		range(0, 22, @(i) {
			$_rows.push([gray, null, null, null, null, null, null, null, null, null, null, gray]);
		}[$]);
		$_rows.push(guard);
		$_filleds = [];
		$_nexts = next7();
		$_tetrimino = null;
		$_direction = 0;
		$_x = 0;
		$_y = 0;
		$_ghost = 0;
		$_already_held = false;
		$_held = null;
		$_hard_drop = null;
		$_hard_drop_direction = 0;
		$_hard_drop_x = 0;
		$_hard_drop_y0 = 0;
		$_hard_drop_y1 = 0;
		$_speed_to_next = 20;
		$_speed_to_drop = 100;
		$_speed_to_fix = 100;
		$_speed_to_clear = 100;
		$_speed_to_hold = 20;
		$_speed_to_fade_hard_drop = 40;
		$_ticks_to_next = 0;
		$_ticks_to_wait = 0;
		$_ticks_to_hold = 0;
		$_ticks_to_fade_hard_drop = 0;
		$_tick = null;
		$_slide_pressed = 0;
		$_pulse_slide = 0;
		$_ticks_to_repeat_slide = 0;
		$_drop_pressed = false;
		$_pulse_drop = false;
		$_ticks_to_repeat_drop = 0;
		$lines = 0;
		$score = 0;
		$draw();
		if ($on_clear !== null) $on_clear();
	};
	$next = @{
		if ($_nexts.size() < 4) next7().each(@(i) { $_nexts.push(i); }[$]);
		$_ticks_to_next = $_speed_to_next;
		$_already_held = false;
		tetriminos[$_nexts.shift()];
	};
	$send = @(tetrimino) {
		$_tetrimino = tetrimino;
		$_direction = 0;
		$_x = 4;
		$_y = 2;
		$_ghost = $_tetrimino.ghost($_rows, $_direction, $_x, $_y);
		if ($_tetrimino.conflicts($_rows, $_direction, $_x, $_y)) {
			$_tetrimino.fix($_rows, $_direction, $_x, $_y);
			$_tetrimino = null;
			$_hard_drop = null;
			$_ticks_to_next = $_ticks_to_hold = $_ticks_to_fade_hard_drop = 0;
			$_sound_bgm.stop();
			$_sound_over.play();
			$_timer.stop();
			$draw();
		} else {
			$_ticks_to_wait = $_speed_to_drop;
			$_tick = $tick_drop;
		}
	};
	$clear = @{
		cleareds = [];
		$_filleds.each(@(i) {
			row = $_rows[i];
			range(1, 11, @(i) row[i] = null);
			cleareds.push(row);
		}[$]);
		i0 = cleareds.size() - 1;
		row = cleareds[i0];
		i1 = i2 = $_rows.size();
		while (i1 > 2) {
			i1 = i1 - 1;
			if ($_rows[i1] !== row) {
				i2 = i2 - 1;
				$_rows[i2] = $_rows[i1];
			} else if (i0 > 0) {
				i0 = i0 - 1;
				row = cleareds[i0];
			} else {
				row = null;
			}
		}
		while (i2 > 2) {
			i2 = i2 - 1;
			$_rows[i2] = cleareds.pop();
		}
		n = $_filleds.size();
		$lines = $lines + n;
		$score = $score + n * n;
		$_filleds = [];
		if ($_speed_to_drop > 1) {
			$_speed_to_drop = $_speed_to_drop * 4 / 5;
			if ($_speed_to_drop < 1) $_speed_to_drop = 1;
		}
		if ($on_clear !== null) $on_clear();
		$_sound_clear.play();
	};
	$fix = @{
		$_filleds = $_tetrimino.fix($_rows, $_direction, $_x, $_y);
		if ($_filleds.size() > 0) {
			$_tetrimino = null;
			$_ticks_to_wait = $_speed_to_clear;
			$_tick = $tick_clear;
		} else {
			$send($next());
		}
	};
	$drop = @{
		y = $_y + 1;
		if ($_tetrimino.conflicts($_rows, $_direction, $_x, y)) return false;
		$_y = y;
		$_ticks_to_wait = $_speed_to_drop;
		$_tick = $tick_drop;
		if ($_tetrimino.conflicts($_rows, $_direction, $_x, y + 1)) $_sound_impact.play();
		true;
	};
	$tick_clear = @{
		$_ticks_to_wait = $_ticks_to_wait - 1;
		if ($_ticks_to_wait <= 0) {
			$clear();
			$send($next());
		}
	};
	$tick_fix = @{
		if ($drop()) return;
		$_ticks_to_wait = $_ticks_to_wait - 1;
		if ($_ticks_to_wait <= 0) $fix();
	};
	$tick_drop = @{
		if ($_pulse_drop) {
			$drop();
			$_pulse_drop = false;
		} else if ($_drop_pressed && $_ticks_to_repeat_drop <= 0) {
			$drop();
		} else {
			$_ticks_to_wait = $_ticks_to_wait - 1;
			if ($_ticks_to_wait <= 0 && !$drop()) {
				$_ticks_to_wait = $_speed_to_fix - $_speed_to_drop;
				$_tick = $tick_fix;
			}
		}
	};
	$tick = @{
		if ($_ticks_to_next > 0) $_ticks_to_next = $_ticks_to_next - 1;
		if ($_ticks_to_hold > 0) $_ticks_to_hold = $_ticks_to_hold - 1;
		if ($_ticks_to_fade_hard_drop > 0) $_ticks_to_fade_hard_drop = $_ticks_to_fade_hard_drop - 1;
		if ($_ticks_to_repeat_slide > 0) $_ticks_to_repeat_slide = $_ticks_to_repeat_slide - 1;
		if ($_ticks_to_repeat_drop > 0) $_ticks_to_repeat_drop = $_ticks_to_repeat_drop - 1;
		if ($_tetrimino !== null) {
			dxs = '(0, -1, 1, 0);
			dx = 0;
			if ($_pulse_slide != 0) {
				dx = dxs[$_pulse_slide];
				$_pulse_slide = 0;
			} else if ($_ticks_to_repeat_slide <= 0) {
				dx = dxs[$_slide_pressed];
			}
			if (dx != 0) {
				x = $_x + dx;
				if (!$_tetrimino.conflicts($_rows, $_direction, x, $_y)) {
					$_x = x;
					$_ghost = $_tetrimino.ghost($_rows, $_direction, $_x, $_y);
				}
			}
		}
		if ($_hard_drop !== null && $_ticks_to_fade_hard_drop <= 0) $_hard_drop = null;
		$_tick();
		$draw();
	};
	$start = @{
		if ($_tick !== null) $reset();
		$_sound_bgm.play();
		$_timer.start(10);
		$send($next());
	};
	$hard_drop = @{
		if ($_tetrimino === null) return;
		$_hard_drop = $_tetrimino;
		$_hard_drop_direction = $_direction;
		$_hard_drop_x = $_x;
		$_hard_drop_y0 = $_y;
		while (true) {
			y = $_y + 1;
			if ($_tetrimino.conflicts($_rows, $_direction, $_x, y)) break;
			$_y = y;
		}
		$_hard_drop_y1 = $_y;
		$_ticks_to_fade_hard_drop = $_speed_to_fade_hard_drop;
		if ($_y > $_hard_drop_y0) $_sound_impact.play();
		$fix();
	};
	$press_slide = @(x) {
		$_slide_pressed = $_slide_pressed | x;
		$_pulse_slide = $_pulse_slide | x;
		$_ticks_to_repeat_slide = 20;
	};
	$release_slide = @(x) {
		$_slide_pressed = $_slide_pressed & ~x;
		$_ticks_to_repeat_slide = 0;
	};
	$press_left = @() $press_slide(1);
	$release_left = @() $release_slide(1);
	$press_right = @() $press_slide(2);
	$release_right = @() $release_slide(2);
	$press_drop = @{
		$_drop_pressed = true;
		$_pulse_drop = true;
		$_ticks_to_repeat_drop = 20;
	};
	$release_drop = @{
		$_drop_pressed = false;
		$_ticks_to_repeat_drop = 0;
	};
	$rotate_left = @{
		if ($_tetrimino === null) return;
		direction = ($_direction + 3) % 4;
		xy = $_tetrimino.try_rotate_left($_rows, direction, $_x, $_y);
		if (xy === null) return;
		$_direction = direction;
		$_x = xy[0];
		$_y = xy[1];
		$_ghost = $_tetrimino.ghost($_rows, $_direction, $_x, $_y);
	};
	$rotate_right = @{
		if ($_tetrimino === null) return;
		direction = ($_direction + 1) % 4;
		xy = $_tetrimino.try_rotate_right($_rows, direction, $_x, $_y);
		if (xy === null) return;
		$_direction = direction;
		$_x = xy[0];
		$_y = xy[1];
		$_ghost = $_tetrimino.ghost($_rows, $_direction, $_x, $_y);
	};
	$hold = @{
		if ($_tetrimino === null || $_already_held) return;
		held = $_held;
		$_held = $_tetrimino;
		$send(held === null ? $next() : held);
		$_already_held = true;
		$_ticks_to_hold = $_speed_to_hold;
		$_sound_hold.play();
	};
};

Score = Class(xraft.Widget) :: @{
	$on_move = @{
		$invalidate_all();
	};
	$draw_right_aligned_text = @(context, x, y, text) {
		extents = context.text_extents(text);
		context.move_to(x - extents[0] - extents[2], y);
		context.show_text(text);
	};
	$draw_texts = @(context, size, x, y, texts) {
		context.set_font_size(size);
		texts.each(@(text) {
			:y = y + size;
			context.move_to(x, y);
			context.show_text(text);
		});
	};
	$on_paint = draw_with_cairo(@(context) {
		extent = $geometry();
		context.rectangle(0.0, 0.0, Float(extent.width()), Float(extent.height()));
		context.set_source_rgb(1.0, 1.0, 1.0);
		context.fill();
		context.select_font_face("Sans", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL);
		context.set_source_rgb(0.0, 0.0, 0.0);
		context.set_font_size(32.0);
		y = 32.0;
		context.move_to(0.0, y);
		context.show_text("LINES");
		y = y + 32.0;
		$draw_right_aligned_text(context, extent.width() - 4, y, $_stage.lines.__string());
		y = y + 32.0;
		context.move_to(0.0, y);
		context.show_text("SCORE");
		y = y + 32.0;
		$draw_right_aligned_text(context, extent.width() - 4, y, $_stage.score.__string());
		y = y + 32.0;
		$draw_texts(context, 16.0, 0.0, y, '(
			"Q: Quit",
			"R: Reset",
			"N: Start New Game",
			"Z: Rotate Left",
			"X: Rotate Right",
			"Space: Hard Drop",
			"Left Shift: Hold",
			"Left: Move Left",
			"Right: Move Right",
			"Down: Soft Drop"
		));
	});
	$__initialize = @(stage) {
		:$^__initialize[$]();
		$_stage = stage;
	};
	$invalidate_all = @{
		extent = $geometry();
		$invalidate(0, 0, extent.width(), extent.height());
	};
};

Frame = Class(xraft.Frame) :: @{
	$on_move = @{
		extent = $geometry();
		width = $_stage.width;
		height = $_stage.height;
		x = extent.width() - width;
		y = (extent.height() - height) / 2;
		$_stage.move(xraft.Rectangle(x, y, width, height));
		$_score.move(xraft.Rectangle(0, y, x, height));
		$invalidate(0, 0, extent.width(), extent.height());
	};
	$on_paint = draw_with_cairo(@(context) {
		extent = $geometry();
		context.rectangle(0.0, 0.0, Float(extent.width()), Float(extent.height()));
		context.set_source_rgb(1.0, 1.0, 1.0);
		context.fill();
	});
	$on_key_press = @(modifier, key, ascii) {
		try {
			$_key_press[key]();
		} catch (Throwable e) {
		}
	};
	$on_key_release = @(modifier, key, ascii) {
		try {
			$_key_release[key]();
		} catch (Throwable e) {
		}
	};
	$on_close = @{
		xraft.application().exit();
	};
	$__initialize = @(context) {
		:$^__initialize[$]();
		$_stage = Stage(context);
		$add($_stage);
		$_score = Score($_stage);
		$_stage.on_clear = $_score.invalidate_all;
		$add($_score);
		$_key_press = {
			xraft.Key.LEFT: $_stage.press_left,
			xraft.Key.RIGHT: $_stage.press_right,
			xraft.Key.DOWN: $_stage.press_drop,
			xraft.Key.SPACE: $_stage.hard_drop,
			xraft.Key.SHIFT_L: $_stage.hold,
			xraft.Key.N: $_stage.start,
			xraft.Key.Q: $on_close,
			xraft.Key.R: $_stage.reset,
			xraft.Key.X: $_stage.rotate_right,
			xraft.Key.Z: $_stage.rotate_left
		};
		$_key_release = {
			xraft.Key.LEFT: $_stage.release_left,
			xraft.Key.RIGHT: $_stage.release_right,
			xraft.Key.DOWN: $_stage.release_drop
		};
		$caption__("Tetris");
		$move(xraft.Rectangle(0, 0, 480, $_stage.height + 32));
	};
};

xraft.main(system.arguments, @(application) {
	cairo.main(@{
		al.main(@{
			device = al.Device(null);
			#context = device.create_context();
			context = device.default_context();
			frame = Frame(context);
			application.add(frame);
			frame.show();
			application.run();
		});
	});
});
