#version 410

uniform mat4 u_mvp;

in vec4 a_pos;
in vec4 a_col;
in vec4 a_normal;

out vec4 v_pos;
out vec4 v_col;
out vec4 v_normal;

void main( )
{
	v_col = a_col;
	v_normal = u_mvp * vec4( a_normal.x, a_normal.y, a_normal.z, 0 );
	v_pos = u_mvp * a_pos;
	gl_Position = v_pos;
}
