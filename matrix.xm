math = Module("math");

SingularMatrixException = Class(Throwable);

Matrix = @(N) Class() :: @{
	$N = N;
	LU = Class() :: @{
		Row = Class() :: @{
			$__initialize = @(i) {
				$i = i;
				$w = 0.0;
				$m = [];
				for (i = 0; i < N; i = i + 1) $m.push(0.0);
			};
			$initialize = @(ds) {
				m = $m;
				m[0] = ds[0];
				d = math.fabs(m[0]);
				for (i = 1; i < N; i = i + 1) {
					m[i] = ds[i];
					d0 = math.fabs(m[i]);
					if (d0 > d) d = d0;
				}
				if (d == 0.0) return false;
				$w = 1.0 / d;
				true;
			};
			$pivot = @(i) $w * math.fabs($m[i]);
			$erase = @(d, i, ds) {
				m = $m;
				m[i] = m[i] / d;
				for (j = i + 1; j < N; j = j + 1) m[j] = m[j] - m[i] * ds[j];
			};
		};

		$__initialize = @{
			rows = [];
			for (i = 0; i < N; i = i + 1) rows.push(Row(i));
			$rows = rows;
		};
		$initialize = @(x) {
			for (i = 0; i < N; i = i + 1) if (!$rows[i].initialize(x[i])) return false;
			true;
		};
		$pivot = @(i) {
			rows = $rows;
			d = rows[i].pivot(i);
			p = i;
			for (j = i + 1; j < N; j = j + 1) {
				d0 = rows[j].pivot(i);
				if (d0 <= d) continue;
				d = d0;
				p = j;
			}
			p;
		};
		$erase = @(i, d) {
			rows = $rows;
			ds = rows[i].m;
			for (j = i + 1; j < N; j = j + 1) rows[j].erase(d, i, ds);
		};
		$decompose = @(x) {
			if (!$initialize(x)) return false;
			for (i = 0; i < N - 1; i = i + 1) {
				p = $pivot(i);
				if (p != i) {
					t = $rows[i];
					$rows[i] = $rows[p];
					$rows[p] = t;
				}
				d = $rows[i].m[i];
				if (d == 0.0) return false;
				$erase(i, d);
			}
			$rows[N - 1].m[N - 1] != 0.0;
		};
		$backsubstitute = @(x) {
			for (j = 0; j < N; j = j + 1) {
				for (i = 0; i < N; i = i + 1) {
					ds = $rows[i].m;
					d = $rows[i].i == j ? 1.0 : 0.0;
					for (k = 0; k < i; k = k + 1) d = d - ds[k] * x[k][j];
					x[i][j] = d;
				}
				while (true) {
					i = i - 1;
					ds = $rows[i].m;
					d = x[i][j];
					for (k = i + 1; k < N; k = k + 1) d = d - ds[k] * x[k][j];
					x[i][j] = d / ds[i];
					if (i <= 0) break;
				}
			}
		};
		$determinant = @(x) {
			if (!$initialize(x)) return 0.0;
			determinant = 1.0;
			for (i = 0; i < N - 1; i = i + 1) {
				p = $pivot(i);
				if (p != i) {
					t = $rows[i];
					$rows[i] = $rows[p];
					$rows[p] = t;
					determinant = -determinant;
				}
				d = $rows[i].m[i];
				if (d == 0.0) return 0.0;
				determinant = determinant * d;
				$erase(i, d);
			}
			determinant * $rows[N - 1].m[N - 1];
		};
	};

	$__initialize = @(value = 1.0) {
		v = [];
		if (value.: === Float) {
			for (i = 0; i < N; i = i + 1) {
				u = [];
				for (j = 0; j < i; j = j + 1) u.push(0.0);
				u.push(value);
				for (j = i + 1; j < N; j = j + 1) u.push(0.0);
				v.push(u);
			}
		} else if (N > value.N) {
			n = value.N;
			for (i = 0; i < n; i = i + 1) {
				u0 = value[i];
				u1 = [];
				for (j = 0; j < n; j = j + 1) u1.push(u0[j]);
				for (j = n; j < N; j = j + 1) u.push(0.0);
				v.push(u1);
			}
			for (i = n; i < N; i = i + 1) {
				u = [];
				for (j = 0; j < i; j = j + 1) u.push(0.0);
				u.push(1.0);
				for (j = i + 1; j < N; j = j + 1) u.push(0.0);
				v.push(u);
			}
		} else {
			for (i = 0; i < N; i = i + 1) {
				u0 = value[i];
				u1 = [];
				for (j = 0; j < N; j = j + 1) u1.push(u0[j]);
				v.push(u1);
			}
		}
		$v = v;
	};
	$__string = @{
		v = $v;
		s = "";
		for (i = 0; i < N; i = i + 1) {
			u = v[i];
			t = "[";
			for (j = 0; j < N; j = j + 1) t = t + " " + u[j];
			s = s + t + "]\n";
		}
		s;
	};
	$__get_at = @(i) $v[i];
	$__equals = @(value) {
		for (i = 0; i < N; i = i + 1) {
			u0 = $v[i];
			u1 = value[i];
			for (j = 0; j < N; j = j + 1) if (u0[j] != u0[j]) return false;
		}
		true;
	};
	$__not_equals = @(value) !$__equals(value);
	$negate = @{
		v = $v;
		for (i = 0; i < N; i = i + 1) {
			u = v[i];
			for (j = 0; j < N; j = j + 1) u[j] = -u[j];
		}
	};
	$__minus = @{
		x = :$($);
		x.negate();
		x;
	};
	$add = @(value) {
		v = $v;
		for (i = 0; i < N; i = i + 1) {
			u0 = v[i];
			u1 = value[i];
			for (j = 0; j < N; j = j + 1) u0[j] = u0[j] + u1[j];
		}
	};
	$__add = @(value) {
		x = :$($);
		x.add(value);
		x;
	};
	$subtract = @(value) {
		v = $v;
		for (i = 0; i < N; i = i + 1) {
			u0 = v[i];
			u1 = value[i];
			for (j = 0; j < N; j = j + 1) u0[j] = u0[j] - u1[j];
		}
	};
	$__subtract = @(value) {
		x = :$($);
		x.subtract(value);
		x;
	};
	$multiply = @(value) {
		v = $v;
		if (value.: === Float) {
			for (i = 0; i < N; i = i + 1) {
				u = v[i];
				for (j = 0; j < N; j = j + 1) u[j] = u[j] * value;
			}
		} else {
			for (i = 0; i < N; i = i + 1) {
				u = v[i];
				ds = [];
				for (j = 0; j < N; j = j + 1) ds.push(u[j]);
				for (j = 0; j < N; j = j + 1) {
					d = 0.0;
					for (k = 0; k < N; k = k + 1) d = d + ds[k] * value[k][j];
					u[j] = d;
				}
			}
		}
	};
	$__multiply = @(value) {
		x = :$($);
		x.multiply(value);
		x;
	};
	$divide = @(value) $multiply(1.0 / value);
	$__divide = @(value) $__multiply(1.0 / value);
	$invert = @{
		lu = LU();
		if (!lu.decompose($)) throw SingularMatrixException($__string());
		lu.backsubstitute($);
	};
	$__complement = @{
		x = :$($);
		x.invert();
		x;
	};
	$equals = @(value, epsilon) {
		for (i = 0; i < N; i = i + 1) {
			u0 = $v[i];
			u1 = value[i];
			for (j = 0; j < N; j = j + 1) if (math.fabs(u0[i] - u1[i]) > epsilon) return false;
		}
		true;
	};
	$transpose = @{
		v = $v;
		n = N - 1;
		for (i = 0; i < n; i = i + 1) {
			for (j = i + 1; j < N; j = j + 1) {
				t = v[i][j];
				v[i][j] = v[j][i];
				v[j][i] = t;
			}
		}
	};
	$transposition = @{
		x = :$($);
		x.transpose();
		x;
	};
	$determinant = @() LU().determinant($);
};

Matrix3 = Matrix(3);
Matrix4 = Matrix(4);

Vector3 = Class() :: @{
	$__initialize = @(x, y, z) {
		$x = x;
		$y = y;
		$z = z;
	};
	$add = @(value) {
		$x = $x + value.x;
		$y = $y + value.y;
		$z = $z + value.z;
	};
	$subtract = @(value) {
		$x = $x - value.x;
		$y = $y - value.y;
		$z = $z - value.z;
	};
	$negate = @{
		$x = -$x;
		$y = -$y;
		$z = -$z;
	};
	$scale = @(value) {
		$x = $x * value.x;
		$y = $y * value.y;
		$z = $z * value.z;
	};
	$__equals = @(value) {
		$x == value.x && $y == value.y && $z == value.z;
	};
	$equals = @(value, epsilon) {
		if (math.fabs($x - value.x) > epsilon) return false;
		if (math.fabs($y - value.y) > epsilon) return false;
		if (math.fabs($z - value.z) > epsilon) return false;
		true;
	};
	$absolute = @{
		$x = math.fabs($x);
		$y = math.fabs($y);
		$z = math.fabs($z);
	};
	$interpolate = @(value, t) {
		$x = (1.0 - t) * $x + t * value.x;
		$y = (1.0 - t) * $y + t * value.y;
		$z = (1.0 - t) * $z + t * value.z;
	};
	$__minus = @() Vector3(-$x, -$y, -$z);
	$__add = @(value) Vector3($x + value.x, $y + value.y, $z + value.z);
	$__subtract = @(value) Vector3($x - value.x, $y - value.y, $z - value.z);
	$__multiply = @(value) value.: === Float ? Vector3($x * value, $y * value, $z * value) : $x * value.x + $y * value.y + $z * value.z;
	$__divide = @(value) Vector3($x / value, $y / value, $z / value);
	$__xor = @(value) Vector3($y * value.z - $z * value.y, $z * value.x - $x * value.z, $x * value.y - $y * value.x);
	$length = @() math.sqrt($ * $);
	$normalize = @() $scale(1.0 / $length());
	$normalized = @() $ / $length();
	$angle = @(value) {
		d = $ * value / ($length() * value.length());
		return math.acos(d < -1.0 ? -1.0 : d > 1.0 ? 1.0 : d);
	};
};

Vector4 = Class() :: @{
	$__initialize = @(x, y, z, w) {
		$x = x;
		$y = y;
		$z = z;
		$w = w;
	};
	$add = @(value) {
		$x = $x + value.x;
		$y = $y + value.y;
		$z = $z + value.z;
		$w = $w + value.w;
	};
	$subtract = @(value) {
		$x = $x - value.x;
		$y = $y - value.y;
		$z = $z - value.z;
		$w = $w - value.w;
	};
	$negate = @{
		$x = -$x;
		$y = -$y;
		$z = -$z;
		$w = -$w;
	};
	$scale = @(value) {
		$x = $x * value.x;
		$y = $y * value.y;
		$z = $z * value.z;
		$w = $w * value.w;
	};
	$__equals = @(value) {
		$x == value.x && $y == value.y && $z == value.z && $w == value.w;
	};
	$equals = @(value, epsilon) {
		if (math.fabs($x - value.x) > epsilon) return false;
		if (math.fabs($y - value.y) > epsilon) return false;
		if (math.fabs($z - value.z) > epsilon) return false;
		if (math.fabs($w - value.w) > epsilon) return false;
		true;
	};
	$absolute = @{
		$x = math.fabs($x);
		$y = math.fabs($y);
		$z = math.fabs($z);
		$w = math.fabs($w);
	};
	$interpolate = @(value, t) {
		$x = (1.0 - t) * $x + t * value.x;
		$y = (1.0 - t) * $y + t * value.y;
		$z = (1.0 - t) * $z + t * value.z;
		$w = (1.0 - t) * $w + t * value.w;
	};
	$__minus = @() Vector4(-$x, -$y, -$z, -$w);
	$__add = @(value) Vector4($x + value.x, $y + value.y, $z + value.z, $w + value.w);
	$__subtract = @(value) Vector4($x - value.x, $y - value.y, $z - value.z, $w - value.w);
	$__multiply = @(value) value.: === Float ? Vector4($x * value, $y * value, $z * value, $w * value) : $x * value.x + $y * value.y + $z * value.z + $w * value.w;
	$__divide = @(value) Vector4($x / value, $y / value, $z / value, $w / value);
	$__xor = @(value) Vector3($y * value.z - $z * value.y, $z * value.x - $x * value.z, $x * value.y - $y * value.x);
	$length = @() math.sqrt($ * $);
	$normalize = @() $scale(1.0 / $length());
	$normalized = @() $ / $length();
	$angle = @(value) {
		d = $ * value / ($length() * value.length());
		return math.acos(d < -1.0 ? -1.0 : d > 1.0 ? 1.0 : d);
	};
};

Matrix3__multiply = Matrix3.__multiply;
Matrix3.__multiply = @(value) {
	if (value.: === Vector3) {
		u0 = $v[0];
		u1 = $v[1];
		u2 = $v[2];
		Vector3(
			u0[0] * value.x + u0[1] * value.y + u0[2] * value.z,
			u1[0] * value.x + u1[1] * value.y + u1[2] * value.z,
			u2[0] * value.x + u2[1] * value.y + u2[2] * value.z
		);
	} else {
		Matrix3__multiply[$](value);
	}
};

Matrix4__multiply = Matrix4.__multiply;
Matrix4.__multiply = @(value) {
	if (value.: === Vector3) {
		u0 = $v[0];
		u1 = $v[1];
		u2 = $v[2];
		u3 = $v[3];
		Vector3(
			u0[0] * value.x + u0[1] * value.y + u0[2] * value.z + u0[3],
			u1[0] * value.x + u1[1] * value.y + u1[2] * value.z + u1[3],
			u2[0] * value.x + u2[1] * value.y + u2[2] * value.z + u2[3]
		);
	} else if (value.: === Vector4) {
		u0 = $v[0];
		u1 = $v[1];
		u2 = $v[2];
		u3 = $v[3];
		Vector4(
			u0[0] * value.x + u0[1] * value.y + u0[2] * value.z + u0[3] * value.w,
			u1[0] * value.x + u1[1] * value.y + u1[2] * value.z + u1[3] * value.w,
			u2[0] * value.x + u2[1] * value.y + u2[2] * value.z + u2[3] * value.w,
			u3[0] * value.x + u3[1] * value.y + u3[2] * value.z + u3[3] * value.w
		);
	} else {
		Matrix4__multiply[$](value);
	}
};

Matrix4.translate = @(x, y, z) {
	for (i = 0; i < 3; i = i + 1) {
		u = $v[i];
		u[3] = u[0] * x + u[1] * y + u[2] * z + u[3];
	}
};

Matrix4.scale = @(x, y, z) {
	for (i = 0; i < 3; i = i + 1) {
		u = $v[i];
		u[0] = u[0] * x;
		u[1] = u[1] * y;
		u[2] = u[2] * z;
	}
};

Matrix4.rotate = @(axis, angle) {
	d = axis.length();
	if (d < 0.0000000001) return;
	x = axis.x / d;
	y = axis.y / d;
	z = axis.z / d;
	s = math.sin(angle);
	c = math.cos(angle);
	d0 = 1.0 - c;
	zx = z * x;
	xy = x * y;
	yz = y * z;
	m = Matrix4();
	u = m[0];
	u[0] = d0 * x * x + c;
	u[1] = d0 * xy - s * z;
	u[2] = d0 * zx + s * y;
	u = m[1];
	u[0] = d0 * xy + s * z;
	u[1] = d0 * y * y + c;
	u[2] = d0 * yz - s * x;
	u = m[2];
	u[0] = d0 * zx - s * y;
	u[1] = d0 * yz + s * x;
	u[2] = d0 * z * z + c;
	$multiply(m);
};

Matrix4.frustum = @(left, right, bottom, top, near, far) {
	m = Matrix4(0.0);
	m[0][0] = 2.0 * near / (right - left);
	m[0][2] = (right + left) / (right - left);
	m[1][1] = 2.0 * near / (top - bottom);
	m[1][2] = (top + bottom) / (top - bottom);
	m[2][2] = -(far + near) / (far - near);
	m[2][3] = -2.0 * far * near / (far - near);
	m[3][2] = -1.0;
	$multiply(m);
};

$Matrix3 = Matrix3;
$Matrix4 = Matrix4;
$Vector3 = Vector3;
$Vector4 = Vector4;
