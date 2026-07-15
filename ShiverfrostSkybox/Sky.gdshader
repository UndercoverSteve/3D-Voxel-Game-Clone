shader_type sky;

uniform samplerCube cubemap : source_color, filter_linear_mipmap;

void sky() {
    COLOR = texture(cubemap, EYEDIR).rgb;
}
