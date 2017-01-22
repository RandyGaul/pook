#version 410

in vec4 v_pos;
in vec2 texCoords;

out vec2 TexCoords;

void main()
{
	gl_Position = vec4(v_pos.x, v_pos.y, 0.0f, 1.0f);
	TexCoords = texCoords;
}