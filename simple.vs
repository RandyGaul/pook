uniform mat4 u_mvp;

attribute vec4 a_pos;
attribute vec4 a_col;
attribute vec4 a_normal;

varying vec4 v_pos;
varying vec4 v_col;
varying vec4 v_normal;

void main( )
{
	v_col = a_col;
	v_normal = a_normal;
	v_pos = u_mvp * a_pos;
	gl_Position = v_pos;
}
