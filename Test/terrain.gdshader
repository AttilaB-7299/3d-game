shader_type spatial;

varying vec4 vert_color;

void vertex() {
	// Capture the vertex color sent from your Chunk script
	vert_color = COLOR;
}

void fragment() {
	// Apply the vertex color to the material's albedo
	ALBEDO = vert_color.rgb;
}