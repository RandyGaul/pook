#version 410
in vec2 a_pos;
in vec2 texCoords;

out vec2 TexCoords;

void main()
{
	gl_Position = vec4(a_pos.x, a_pos.y, 0.0f, 1.0f);
	TexCoords = texCoords;
}