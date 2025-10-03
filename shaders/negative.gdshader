shader_type canvas_item;

void fragment() {
	COLOR = vec4(1.0 - COLOR.r,1.0 - COLOR.g,1.0 - COLOR.b, COLOR.a);
}
