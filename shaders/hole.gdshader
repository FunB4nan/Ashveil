shader_type canvas_item;

uniform vec2 size;
uniform vec2 scale;
uniform vec2 position;

vec2 uv(vec2 uv) {
    vec2 s = vec2(size.x / scale.x, size.x / scale.y);
    vec2 p = vec2(position.x / (size.x / s.x), position.y / (size.y / s.y));
	vec2 result = vec2(uv.x * s.x - p.x, uv.y * s.y - p.y);
	if (result.x>=1.0 ||result.x<=0.0||result.y<=0.0||result.y>=1.0){
		result.x=0.0;
	}
	return result;
}

void fragment() {
	vec2 result_uv =uv(UV);
	
	if(result_uv.x!=0.0){
		COLOR.a = 0.0;
	}
    
}