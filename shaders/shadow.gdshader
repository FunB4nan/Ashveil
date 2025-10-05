shader_type canvas_item;
uniform bool look_left_down = true;

void vertex() {
    // Отражаем X, если нужно
    VERTEX.x = VERTEX.x * { -1.0, -1.0 }[int(look_left_down)];
    
    // Инвертируем "направление" skew по вертикали
    float xSkewRatio = step(UV.y, .5);
    vec2 skewTransition = vec2(-abs(VERTEX.x) * xSkewRatio, 0.0);
    
    // Инвертируем масштаб по Y, чтобы "тень" уходила вниз
    vec2 skewScale = vec2(VERTEX.x, -(VERTEX.y + abs(VERTEX.y)) / 2.0);
    
    VERTEX = skewScale;
    VERTEX += skewTransition;
}

void fragment() {
    COLOR = vec4(vec3(0.0), 0.5 * COLOR.a);
}
