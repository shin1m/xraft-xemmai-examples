system = Module("system"
print = system.error.write_line
math = Module("math"
matrix = Module("matrix"
xraft = Module("xraft"
cairo = Module("cairo"
gl = Module("gl"

range = @(i, j, callable) for ; i < j; i = i + 1
	callable(i

Matrix3 = matrix.Matrix3
Matrix4 = matrix.Matrix4
Vector3 = matrix.Vector3
Vector4 = matrix.Vector4

Matrix__bytes = @
	N = $N
	bytes = Bytes(N * N * gl.Float32Array.BYTES_PER_ELEMENT
	v = $v
	array = gl.Float32Array(bytes
	range(0, N, @(i) range(0, N, @(j) array[i * N + j] = v[i][j]
	bytes
Matrix3.bytes = Matrix__bytes
Matrix4.bytes = Matrix__bytes

Gear = Class() :: @
	# flat shading + uniform color + uniform mvp
	FACE_VSHADER = "
attribute vec3 vertex;
uniform mat4 vertexMatrix;
uniform mat4 textureMatrix;
varying vec2 texCoord;

void main()
{
	vec4 v = vec4(vertex, 1.0);
	gl_Position = vertexMatrix * v;
	texCoord = (textureMatrix * v).xy;
}
	"

	FACE_FSHADER = "
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec2 texCoord;
uniform vec4 color;
uniform sampler2D texture;

void main()
{
	gl_FragColor = color * 0.5 + texture2D(texture, texCoord) * 0.5;
}
	"

	# flat shading - each normal across polygon is constant
	# per-vertex normal + uniform color + uniform mvp
	OUTWARD_VSHADER = "
attribute vec3 vertex;
attribute vec3 normal;
uniform vec4 color;
uniform mat3 normalMatrix;
uniform mat4 vertexMatrix;
varying vec4 varying_color;

void main()
{
	vec3 light = normalize(vec3(5.0, 5.0, 10.0));
	vec4 c = vec4(0.2, 0.2, 0.2, 1.0);
	float d = dot(normalize(normalMatrix * normal), light);
	if (d > 0.0) c += vec4(d, d, d, 0.0);
	varying_color = color * c;
	gl_Position = vertexMatrix * vec4(vertex, 1.0);
}
	"

	OUTWARD_FSHADER = "
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 varying_color;

void main()
{
	gl_FragColor = varying_color;
}
	"

	# smooth shading + per-vertex normal + uniform color + uniform mvp
	CYLINDER_VSHADER = "
attribute vec3 vertex;
attribute vec3 normal;
uniform mat3 normalMatrix;
uniform mat4 vertexMatrix;
varying vec3 varying_normal;

void main()
{
	varying_normal = normalize(normalMatrix * normal);
	gl_Position = vertexMatrix * vec4(vertex, 1.0);
}
	"

	CYLINDER_FSHADER = "
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec4 color;
varying vec3 varying_normal;

void main()
{
	vec3 light = normalize(vec3(5.0, 5.0, 10.0));
	vec4 c = vec4(0.2, 0.2, 0.2, 1.0);
	float d  = dot(varying_normal, light);
	if (d > 0.0) c += vec4(d, d, d, 0.0);
	gl_FragColor = color * c;
}
	"

	Vertices = Class() :: @
		$__initialize = @
			$_normal = '(0.0, 0.0, 1.0
			$_vertices = [
			$_normals = [
		$vertex3f = @(x, y, z)
			$_vertices.push(x
			$_vertices.push(y
			$_vertices.push(z
			$_normals.push($_normal[0]
			$_normals.push($_normal[1]
			$_normals.push($_normal[2]
		$normal3f = @(x, y, z) $_normal = '(x, y, z
		transfer = @(floats, buffer)
			bytes = Bytes(floats.size() * gl.Float32Array.BYTES_PER_ELEMENT
			array = gl.Float32Array(bytes
			range(0, floats.size(), @(i) array[i] = floats[i]
			gl.bind_buffer(gl.ARRAY_BUFFER, buffer
			gl.buffer_data(gl.ARRAY_BUFFER, bytes, gl.STATIC_DRAW
			buffer.count = floats.size() / 3
		$vertices = @(buffer) transfer($_vertices, buffer
		$normals = @(buffer) transfer($_normals, buffer
	load_rgba = @(path)
		image0 = cairo.ImageSurface.create_from_file(path
		width = image0.get_width(
		height = image0.get_height(
		try
			image1 = cairo.ImageSurface(cairo.Format.ARGB32, width, height
			try
				context = cairo.Context(image1
				try
					context.set_source(image0, 0.0, 0.0
					context.paint(
				finally
					context.release(
				data = image1.get_data(
				range(0, width * height, @(i)
					t = data[i * 4]
					data[i * 4] = data[i * 4 + 2]
					data[i * 4 + 2] = t
				'(width, height, data
			finally
				image1.release(
		finally
			image0.release(
	angle = @(i, teeth)
		angle = i * 2.0 * math.PI / teeth
		da = 2.0 * math.PI / teeth / 4.0
		'(angle, angle + 1.0 * da, angle + 2.0 * da, angle + 3.0 * da
	$generate = @(inner, outer, width, teeth, depth, image)
		rgba = load_rgba(image
		gl.active_texture(gl.TEXTURE0
		gl.bind_texture(gl.TEXTURE_2D, $_texture
		gl.tex_image2d(gl.TEXTURE_2D, 0, gl.RGBA, rgba[0], rgba[1], 0, gl.RGBA, gl.UNSIGNED_BYTE, rgba[2]
		gl.tex_parameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST
		gl.tex_parameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR
		gl.bind_texture(gl.TEXTURE_2D, null

		r0 = inner
		r1 = outer - depth / 2.0
		r2 = outer + depth / 2.0
		dz = 0.5 * width
		$_texture_matrix = matrix.Matrix4(
		$_texture_matrix.translate(0.5, 0.5, 0.0
		$_texture_matrix.scale(0.5 / r2, -0.5 / r2, 1.0
		# draw front face
		# GL_TRIANGLE_STRIP
		vertices = Vertices(
		range(0, teeth, @(i)
			as = angle(i, teeth
			vertices.vertex3f(r0 * math.cos(as[0]), r0 * math.sin(as[0]), dz
			vertices.vertex3f(r1 * math.cos(as[0]), r1 * math.sin(as[0]), dz
			vertices.vertex3f(r0 * math.cos(as[0]), r0 * math.sin(as[0]), dz
			vertices.vertex3f(r1 * math.cos(as[3]), r1 * math.sin(as[3]), dz
		vertices.vertex3f(r0 * math.cos(0.0), r0 * math.sin(0.0), dz
		vertices.vertex3f(r1 * math.cos(0.0), r1 * math.sin(0.0), dz
		vertices.vertices($_front_vertices
		# draw front sides of teeth
		# GL_TRIANGLES
		vertices = Vertices(
		range(0, teeth, @(i)
			as = angle(i, teeth
			vertices.vertex3f(r1 * math.cos(as[0]), r1 * math.sin(as[0]), dz   # 0
			vertices.vertex3f(r2 * math.cos(as[1]), r2 * math.sin(as[1]), dz   # 1
			vertices.vertex3f(r2 * math.cos(as[2]), r2 * math.sin(as[2]), dz   # 2
			vertices.vertex3f(r1 * math.cos(as[0]), r1 * math.sin(as[0]), dz   # 0
			vertices.vertex3f(r2 * math.cos(as[2]), r2 * math.sin(as[2]), dz   # 2
			vertices.vertex3f(r1 * math.cos(as[3]), r1 * math.sin(as[3]), dz   # 3
		vertices.vertices($_front_teeth_vertices
		#draw back face
		#GL_TRIANGLE_STRIP
		vertices = Vertices(
		range(0, teeth, @(i)
			as = angle(i, teeth
			vertices.vertex3f(r1 * math.cos(as[0]), r1 * math.sin(as[0]), -dz
			vertices.vertex3f(r0 * math.cos(as[0]), r0 * math.sin(as[0]), -dz
			vertices.vertex3f(r1 * math.cos(as[3]), r1 * math.sin(as[3]), -dz
			vertices.vertex3f(r0 * math.cos(as[0]), r0 * math.sin(as[0]), -dz
		vertices.vertex3f(r1 * math.cos(0.0), r1 * math.sin(0.0), -dz
		vertices.vertex3f(r0 * math.cos(0.0), r0 * math.sin(0.0), -dz
		vertices.vertices($_back_vertices
		# draw back sides of teeth
		# GL_TRIANGLES
		vertices = Vertices(
		range(0, teeth, @(i)
			as = angle(i, teeth
			vertices.vertex3f(r1 * math.cos(as[3]), r1 * math.sin(as[3]), -dz   # 0
			vertices.vertex3f(r2 * math.cos(as[2]), r2 * math.sin(as[2]), -dz   # 1
			vertices.vertex3f(r2 * math.cos(as[1]), r2 * math.sin(as[1]), -dz   # 2
			vertices.vertex3f(r1 * math.cos(as[3]), r1 * math.sin(as[3]), -dz   # 0
			vertices.vertex3f(r2 * math.cos(as[1]), r2 * math.sin(as[1]), -dz   # 2
			vertices.vertex3f(r1 * math.cos(as[0]), r1 * math.sin(as[0]), -dz   # 3
		vertices.vertices($_back_teeth_vertices
		# draw outward faces of teeth
		# GL_TRIANGLE_STRIP
		# repeated vertices are necessary to achieve flat shading in ES2
		vertices = Vertices(
		range(0, teeth, @(i)
			as = angle(i, teeth
			if i > 0
				vertices.vertex3f(r1 * math.cos(as[0]), r1 * math.sin(as[0]), dz
				vertices.vertex3f(r1 * math.cos(as[0]), r1 * math.sin(as[0]), -dz
			u = r2 * math.cos(as[1]) - r1 * math.cos(as[0])
			v = r2 * math.sin(as[1]) - r1 * math.sin(as[0])
			l = math.sqrt(u * u + v * v
			u = u / l
			v = v / l
			vertices.normal3f(v, -u, 0.0
			vertices.vertex3f(r1 * math.cos(as[0]), r1 * math.sin(as[0]), dz
			vertices.vertex3f(r1 * math.cos(as[0]), r1 * math.sin(as[0]), -dz
			vertices.vertex3f(r2 * math.cos(as[1]), r2 * math.sin(as[1]), dz
			vertices.vertex3f(r2 * math.cos(as[1]), r2 * math.sin(as[1]), -dz
			vertices.normal3f(math.cos(as[0]), math.sin(as[0]), 0.0
			vertices.vertex3f(r2 * math.cos(as[1]), r2 * math.sin(as[1]), dz
			vertices.vertex3f(r2 * math.cos(as[1]), r2 * math.sin(as[1]), -dz
			vertices.vertex3f(r2 * math.cos(as[2]), r2 * math.sin(as[2]), dz
			vertices.vertex3f(r2 * math.cos(as[2]), r2 * math.sin(as[2]), -dz
			u = r1 * math.cos(as[3]) - r2 * math.cos(as[2])
			v = r1 * math.sin(as[3]) - r2 * math.sin(as[2])
			vertices.normal3f(v, -u, 0.0
			vertices.vertex3f(r2 * math.cos(as[2]), r2 * math.sin(as[2]), dz
			vertices.vertex3f(r2 * math.cos(as[2]), r2 * math.sin(as[2]), -dz
			vertices.vertex3f(r1 * math.cos(as[3]), r1 * math.sin(as[3]), dz
			vertices.vertex3f(r1 * math.cos(as[3]), r1 * math.sin(as[3]), -dz
			vertices.normal3f(math.cos(as[0]), math.sin(as[0]), 0.0
			vertices.vertex3f(r1 * math.cos(as[3]), r1 * math.sin(as[3]), dz
			vertices.vertex3f(r1 * math.cos(as[3]), r1 * math.sin(as[3]), -dz
		vertices.vertex3f(r1 * math.cos(0.0), r1 * math.sin(0.0), dz
		vertices.vertex3f(r1 * math.cos(0.0), r1 * math.sin(0.0), -dz
		vertices.vertices($_outward_vertices
		vertices.normals($_outward_normals
		# draw inside radius cylinder
		# GL_TRIANGLE_STRIP
		vertices = Vertices(
		range(0, teeth, @(i)
			as = angle(i, teeth
			vertices.normal3f(-math.cos(as[0]), -math.sin(as[0]), 0.0
			vertices.vertex3f(r0 * math.cos(as[0]), r0 * math.sin(as[0]), -dz
			vertices.vertex3f(r0 * math.cos(as[0]), r0 * math.sin(as[0]), dz
		vertices.normal3f(-math.cos(0.0), -math.sin(0.0), 0.0
		vertices.vertex3f(r0 * math.cos(0.0), r0 * math.sin(0.0), -dz
		vertices.vertex3f(r0 * math.cos(0.0), r0 * math.sin(0.0), dz
		vertices.vertices($_cylinder_vertices
		vertices.normals($_cylinder_normals

		gl.bind_buffer(gl.ARRAY_BUFFER, null
	compile = @(type, source)
		shader = gl.Shader(type
		shader.source(source
		shader.compile(
		shader.get_parameteri(gl.COMPILE_STATUS) == gl.FALSE && throw Throwable(source + shader.get_info_log()
		shader
	build = @(vshader, fshader)
		vs = compile(gl.VERTEX_SHADER, vshader
		fs = compile(gl.FRAGMENT_SHADER, fshader
		program = gl.Program(
		program.attach_shader(vs
		program.attach_shader(fs
		vs.delete(
		fs.delete(
		program.link(
		program.get_parameteri(gl.LINK_STATUS) == gl.FALSE && throw Throwable(program.get_info_log(
		program
	$load = @
		# face shaders
		$_face_program = build(FACE_VSHADER, FACE_FSHADER
		$_face_attribute_vertex = $_face_program.get_attrib_location("vertex"
		$_face_uniform_color = $_face_program.get_uniform_location("color"
		$_face_uniform_vertex_matrix = $_face_program.get_uniform_location("vertexMatrix"
		$_face_uniform_texture_matrix = $_face_program.get_uniform_location("textureMatrix"
		$_face_uniform_texture = $_face_program.get_uniform_location("texture"

		# outward teeth shaders
		$_outward_program = build(OUTWARD_VSHADER, OUTWARD_FSHADER
		$_outward_attribute_vertex = $_outward_program.get_attrib_location("vertex"
		$_outward_attribute_normal = $_outward_program.get_attrib_location("normal"
		$_outward_uniform_color = $_outward_program.get_uniform_location("color"
		$_outward_uniform_normal_matrix = $_outward_program.get_uniform_location("normalMatrix"
		$_outward_uniform_vertex_matrix = $_outward_program.get_uniform_location("vertexMatrix"

		# cylinder shaders
		$_cylinder_program = build(CYLINDER_VSHADER, CYLINDER_FSHADER
		$_cylinder_attribute_vertex = $_cylinder_program.get_attrib_location("vertex"
		$_cylinder_attribute_normal = $_cylinder_program.get_attrib_location("normal"
		$_cylinder_uniform_color = $_cylinder_program.get_uniform_location("color"
		$_cylinder_uniform_normal_matrix = $_cylinder_program.get_uniform_location("normalMatrix"
		$_cylinder_uniform_vertex_matrix = $_cylinder_program.get_uniform_location("vertexMatrix"
	$__initialize = @(color, inner, outer, width, teeth, depth, image)
		$_color = color
		$_texture = gl.Texture(
		$_texture_matrix = null
		$_front_vertices = gl.Buffer(
		$_front_teeth_vertices = gl.Buffer(
		$_back_vertices = gl.Buffer(
		$_back_teeth_vertices = gl.Buffer(
		$_outward_vertices = gl.Buffer(
		$_outward_normals = gl.Buffer(
		$_cylinder_vertices = gl.Buffer(
		$_cylinder_normals = gl.Buffer(
		$generate(inner, outer, width, teeth, depth, image
		$load(
	$draw = @(projection, viewing)
		vertex_matrix_bytes = (projection * viewing).bytes(
		normal_matrix = (~Matrix3(viewing)).transposition(
		normal_matrix_bytes = normal_matrix.bytes(
		light_position = Vector3(5.0, 5.0, 10.0).normalized(

		# front, back, front teeth and back teeth
		gl.use_program($_face_program
		gl.enable_vertex_attrib_array($_face_attribute_vertex
		gl.active_texture(gl.TEXTURE0
		gl.bind_texture(gl.TEXTURE_2D, $_texture
		$_face_uniform_texture.uniform1i(0

		# compute color for flat shaded surface
		normal_front = (normal_matrix * Vector3(0.0, 0.0, 1.0)).normalized(
		color = Vector4(0.2, 0.2, 0.2, 1.0   # ambient
		ndotlp = normal_front * light_position
		if ndotlp > 0.0
			color = color + Vector4(ndotlp, ndotlp, ndotlp, 0.0) # ambient + diffuse
		$_face_uniform_color.uniform4f(color.x * $_color.x, color.y * $_color.y, color.z * $_color.z, color.w * $_color.w # color * (ambient + diffuse)
		$_face_uniform_vertex_matrix.matrix4fv(true, vertex_matrix_bytes
		$_face_uniform_texture_matrix.matrix4fv(true, $_texture_matrix.bytes()
		gl.bind_buffer(gl.ARRAY_BUFFER, $_front_vertices
		gl.vertex_attrib_pointer($_face_attribute_vertex, 3, gl.FLOAT, false, 0, 0
		gl.draw_arrays(gl.TRIANGLE_STRIP, 0, $_front_vertices.count

		gl.bind_buffer(gl.ARRAY_BUFFER, $_front_teeth_vertices
		gl.vertex_attrib_pointer($_face_attribute_vertex, 3, gl.FLOAT, false, 0, 0
		gl.draw_arrays(gl.TRIANGLES, 0, $_front_teeth_vertices.count

		# compute color for flat shaded surface
		normal_back = (normal_matrix * Vector3(0.0, 0.0, -1.0)).normalized(
		color = Vector4(0.2, 0.2, 0.2, 1.0   # reload ambient
		ndotlp = normal_back * light_position
		if ndotlp > 0.0
			color = color + Vector4(ndotlp, ndotlp, ndotlp, 0.0) # ambient + diffuse
		$_face_uniform_color.uniform4f(color.x * $_color.x, color.y * $_color.y, color.z * $_color.z, color.w * $_color.w # color * (ambient + diffuse)
		gl.bind_buffer(gl.ARRAY_BUFFER, $_back_vertices
		gl.vertex_attrib_pointer($_face_attribute_vertex, 3, gl.FLOAT, false, 0, 0
		gl.draw_arrays(gl.TRIANGLE_STRIP, 0, $_back_vertices.count
		gl.bind_buffer(gl.ARRAY_BUFFER, $_back_teeth_vertices
		gl.vertex_attrib_pointer($_face_attribute_vertex, 3, gl.FLOAT, false, 0, 0
		gl.draw_arrays(gl.TRIANGLES, 0, $_back_teeth_vertices.count

		gl.disable_vertex_attrib_array($_face_attribute_vertex
		gl.bind_texture(gl.TEXTURE_2D, null

		# outward teeth
		gl.use_program($_outward_program
		gl.enable_vertex_attrib_array($_outward_attribute_vertex
		gl.enable_vertex_attrib_array($_outward_attribute_normal
		$_outward_uniform_color.uniform4f($_color.x, $_color.y, $_color.z, $_color.w
		$_outward_uniform_normal_matrix.matrix3fv(true, normal_matrix_bytes
		$_outward_uniform_vertex_matrix.matrix4fv(true, vertex_matrix_bytes
		gl.bind_buffer(gl.ARRAY_BUFFER, $_outward_vertices
		gl.vertex_attrib_pointer($_outward_attribute_vertex, 3, gl.FLOAT, false, 0, 0
		gl.bind_buffer(gl.ARRAY_BUFFER, $_outward_normals
		gl.vertex_attrib_pointer($_outward_attribute_normal, 3, gl.FLOAT, false, 0, 0
		gl.draw_arrays(gl.TRIANGLE_STRIP, 0, $_outward_vertices.count
		gl.disable_vertex_attrib_array($_outward_attribute_normal
		gl.disable_vertex_attrib_array($_outward_attribute_vertex

		# cylinder
		gl.use_program($_cylinder_program
		gl.enable_vertex_attrib_array($_cylinder_attribute_vertex
		gl.enable_vertex_attrib_array($_cylinder_attribute_normal
		$_cylinder_uniform_color.uniform4f($_color.x, $_color.y, $_color.z, $_color.w
		$_cylinder_uniform_normal_matrix.matrix3fv(true, normal_matrix_bytes
		$_cylinder_uniform_vertex_matrix.matrix4fv(true, vertex_matrix_bytes
		gl.bind_buffer(gl.ARRAY_BUFFER, $_cylinder_vertices
		gl.vertex_attrib_pointer($_cylinder_attribute_vertex, 3, gl.FLOAT, false, 0, 0
		gl.bind_buffer(gl.ARRAY_BUFFER, $_cylinder_normals
		gl.vertex_attrib_pointer($_cylinder_attribute_normal, 3, gl.FLOAT, false, 0, 0
		gl.draw_arrays(gl.TRIANGLE_STRIP, 0, $_cylinder_vertices.count
		gl.disable_vertex_attrib_array($_cylinder_attribute_normal
		gl.disable_vertex_attrib_array($_cylinder_attribute_vertex

		gl.use_program(null
		gl.bind_buffer(gl.ARRAY_BUFFER, null

Gears = Class(xraft.GLWidget) :: @
	$invalidate_all = @
		extent = $geometry(
		$invalidate(0, 0, extent.width(), extent.height()
	$on_create = @
		$_context.make_current($
		$_gear1 = Gear(Vector4(0.8, 0.1, 0.0, 1.0), 1.0, 4.0, 1.0, 20, 0.7, "data/lena.jpg"
		$_gear2 = Gear(Vector4(0.0, 0.8, 0.2, 1.0), 0.5, 2.0, 2.0, 10, 0.7, "data/romedalen.png"
		$_gear3 = Gear(Vector4(0.2, 0.2, 1.0, 1.0), 1.3, 2.0, 0.5, 10, 0.7, "data/romedalen.png"
		gl.enable(gl.CULL_FACE
		gl.enable(gl.DEPTH_TEST
		$on_move(
	$on_move = @ if $created()
		$_context.make_current($
		extent = $geometry(
		gl.viewport(0, 0, extent.width(), extent.height()
		w = Float(extent.width()) / extent.height()
		h = 1.0
		$_projection = Matrix4(
		$_projection.frustum(-w, w, -h, h, 5.0, 60.0
	$on_paint = @(g)
		$_context.make_current($
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
		viewings = [
		viewing = Matrix4(
		viewing.translate(0.0, 0.0, -40.0

		viewings.push(Matrix4(viewing
		viewing.rotate(Vector3(1.0, 0.0, 0.0), $_rotate_x
		viewing.rotate(Vector3(0.0, 1.0, 0.0), $_rotate_y
		viewing.rotate(Vector3(0.0, 0.0, 1.0), $_rotate_z

		viewings.push(Matrix4(viewing
		viewing.translate(-3.0, -2.0, 0.0
		viewing.rotate(Vector3(0.0, 0.0, 1.0), $_angle
		$_gear1.draw($_projection, viewing
		viewing = viewings.pop(

		viewings.push(Matrix4(viewing
		viewing.translate(3.1, -2.0, 0.0
		viewing.rotate(Vector3(0.0, 0.0, 1.0), -2.0 * $_angle - math.PI * 9.0 / 180.0
		$_gear2.draw($_projection, viewing
		viewing = viewings.pop(

		viewings.push(Matrix4(viewing
		viewing.translate(-3.1, 2.2, -1.8
		viewing.rotate(Vector3(1.0, 0.0, 0.0), math.PI * 0.5
		viewing.rotate(Vector3(0.0, 0.0, 1.0), 2.0 * $_angle - math.PI * 2.0 / 180.0
		$_gear3.draw($_projection, viewing
		viewing = viewings.pop(

		viewing = viewings.pop(
		$_context.flush(
	$on_key_press = @(modifier, key, ascii) key == xraft.Key.Q && xraft.application().exit(
	$on_button_press = @(modifier, button, x, y) if $_pressed === null
		$_pressed = '(x, y
		$_origin = '($_rotate_x, $_rotate_y
	$on_button_release = @(modifier, button, x, y) if $_pressed !== null
		$_pressed = $_origin = null
	$on_pointer_move = @(modifier, x, y) if $_pressed !== null
		$_rotate_x = $_origin[0] + math.PI * (y - $_pressed[1]) / 180.0
		$_rotate_y = $_origin[1] + math.PI * (x - $_pressed[0]) / 180.0
		$invalidate_all(
	$__initialize = @(format)
		:$^__initialize[$](format
		$_context = xraft.GLContext(format
		$_rotate_x = math.PI * 20.0 / 180.0
		$_rotate_y = math.PI * 30.0 / 180.0
		$_rotate_z = 0.0
		$_angle = 0.0
		$_pressed = null
		$_origin = null
		$_timer = xraft.Timer((@
			$_angle = $_angle + math.PI * 2.0 / 180.0
			$invalidate_all(
		)[$]
		$_timer.start(30

Frame = Class(xraft.Frame) :: @
	$on_move = @
		extent = $geometry(
		$at(0).move(xraft.Rectangle(0, 0, extent.width(), extent.height()
	$on_focus_enter = @ xraft.application().focus__($at(0
	$on_close = @ xraft.application().exit(
	$__initialize = @
		:$^__initialize[$](
		$add(Gears(xraft.GLFormat(true, true, false, true

xraft.main(system.arguments, @(application) cairo.main(@ gl.main(@
	frame = Frame(
	frame.caption__("OpenGL Gears"
	frame.move(xraft.Rectangle(0, 0, 320, 240
	application.add(frame
	frame.show(
	application.run(
