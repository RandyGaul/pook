
#include <glad/glad.h>
#include <glfw/glfw_config.h>
#include <glfw/glfw3.h>

#define TINYGL_IMPL
#include "tinygl.h"

#include "lua\lua.h"
#include "lua\lualib.h"
#include "lua\lauxlib.h"

#include <stdio.h>
#include <float.h>

GLFWwindow* window;
float projection[ 16 ];
lua_State* L;

void ErrorCB( int error, const char* description )
{
	fprintf( stderr, "Error: %s\n", description );
}

void KeyCB( GLFWwindow* window, int key, int scancode, int action, int mods )
{
	if ( key == GLFW_KEY_ESCAPE && action == GLFW_PRESS )
		glfwSetWindowShouldClose( window, GLFW_TRUE );
}


void Reshape( GLFWwindow* window, int width, int height )
{
	GLfloat aspect = (GLfloat) height / (GLfloat) width;
	float fov = 1.48353f;
	tgPerspective( projection, fov, aspect, 0.1f, 10000.0f );
}

void PookSwapBuffers( )
{
	glfwSwapBuffers( window );
}

typedef struct
{
	float x;
	float y;
	float z;
} v3;

typedef struct
{
	v3 x;
	v3 y;
	v3 z;
} m3;

typedef struct
{
	m3 r;
	v3 p;
} tx;

v3 V3( float x, float y, float z )
{
	v3 v;
	v.x = x;
	v.y = y;
	v.z = z;
	return v;
}

m3 M3( v3 x, v3 y, v3 z )
{
	m3 m;
	m.x = x;
	m.y = y;
	m.z = z;
	return m;
}

v3 add( v3 a, v3 b )
{
	return V3( a.x + b.x, a.y + b.y, a.z + b.z );
}

v3 sub( v3 a, v3 b )
{
	return V3( a.x - b.x, a.y - b.y, a.z - b.z );
}

float dot( v3 a, v3 b )
{
	return a.x * b.x + a.y * b.y + a.z * b.z;
}

v3 cross( v3 a, v3 b )
{
	return V3( a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x* b.y - a.y * b.x );
}

float len( v3 a )
{
	return sqrtf( dot( a, a ) );
}

v3 norm( v3 a )
{
	float inv_len = 1.0f / len( a );
	return V3( inv_len * a.x, inv_len * a.y, inv_len * a.z );
}

v3 v3Mul( m3 m, v3 a )
{
	float x = dot( m.x, a );
	float y = dot( m.y, a );
	float z = dot( m.z, a );
	return V3( x, y, z );
}

m3 m3Mul( m3 a, m3 b )
{
	m3 c;
	c.x = v3Mul( a, b.x );
	c.y = v3Mul( a, b.y );
	c.z = v3Mul( a, b.z );
	return c;
}

m3 m3Identity( )
{
	m3 i;
	i.x = V3( 1, 0, 0 );
	i.x = V3( 0, 1, 0 );
	i.x = V3( 0, 0, 1 );
	return i;
}

tx txIdentity( )
{
	tx i;
	i.r = m3Identity( );
	i.p = V3( 0, 0, 0 );
	return i;
}

tx Translate( v3 a )
{
	tx t;
	t.r = m3Identity( );
	t.p = a;
	return t;
}

v3 txMulv( tx m, v3 v )
{
	v = v3Mul( m.r, v );
	return add( m.p, v );
}

v3 txMulvT( tx m, v3 v )
{
	return v3Mul( m.r, sub( v, m.p ) );
}

m3 m3Rotation( v3 axis, float angle )
{
	float s = sinf( angle );
	float c = cosf( angle );
	float x = axis.x;
	float y = axis.y;
	float z = axis.z;
	float xy = x * y;
	float yz = y * z;
	float zx = z * x;
	float t = 1.0f - c;

	m3 a;
	a.x = V3( x * x * t + c, xy * t + z * s, zx * t - y * s );
	a.y = V3( xy * t - z * s, y * y * t + c, yz * t + x * s );
	a.z = V3( zx * t + y * s, yz * t - x * s, z * z * t + c );
	return a;
}

void txToM4( tx a, float* b )
{
	b[ 0 ] = a.r.x.x;
	b[ 1 ] = a.r.y.x;
	b[ 2 ] = a.r.z.x;
	b[ 3 ] = 0;

	b[ 4 ] = a.r.x.y;
	b[ 5 ] = a.r.y.y;
	b[ 6 ] = a.r.z.y;
	b[ 7 ] = 0;

	b[ 8 ] = a.r.x.z;
	b[ 8 ] = a.r.y.z;
	b[ 10 ] = a.r.z.z;
	b[ 11 ] = 0;

	b[ 12 ]= a.p.x;
	b[ 13 ]= a.p.y;
	b[ 14 ]= a.p.z;
	b[ 15 ]= 1.0f;
}

float absf( float a )
{
	if ( a < 0 ) return -a;
	else return a;
}

void LookAt( float* m, v3 eye, v3 center, v3 up )
{
	v3 front = norm( sub( center, eye ) );
	v3 side = norm( cross( front, up ) );
	v3 top = cross( side, front );
	TG_ASSERT( absf( len( top ) - 1.0f ) < FLT_EPSILON );

	m[ 0 ] = side.x;
	m[ 1 ] = top.x;
	m[ 2 ] = -front.x;
	m[ 3 ] = 0;

	m[ 4 ] = side.y;
	m[ 5 ] = top.y;
	m[ 6 ] = -front.y;
	m[ 7 ] = 0;

	m[ 8 ] = side.z;
	m[ 9 ] = top.z;
	m[ 10 ]= -front.z;
	m[ 11 ]= 0;

	m[ 12 ]= -eye.x;
	m[ 13 ]= -eye.y;
	m[ 14 ]= -eye.z;
	m[ 15 ]= 1.0f;
}

void m4Mul_internal( float a[ 4 ][ 4 ], float b[ 4 ][ 4 ], float* out )
{
	float temp[ 4 ][ 4 ];

	for ( int c = 0; c < 4; ++c )
	{
		for ( int r = 0; r < 4; ++r )
		{
			temp[ c ][ r ] = 0;
			for ( int k = 0; k < 4; ++k )
				temp[ c ][ r ] += a[ k ][ r ] * b[ c ][ k ];
		}
	}

	for ( int i = 0; i < 16; ++i )
		out[ i ] = ((float*)temp)[ i ];
}

void m4Mul( float* a, float* b, float* c )
{
	m4Mul_internal( (float(*)[ 4 ])a, (float(*)[ 4 ])b, c );
}

void m4Identity( float* m )
{
	memset( m, 0, sizeof( float ) * 16 );
	m[ 0 ] = 1.0f;
	m[ 5 ] = 1.0f;
	m[ 10 ] = 1.0f;
	m[ 15 ] = 1.0f;
}

typedef struct
{
	v3 position;
	v3 color;
	v3 normal;
} Vertex;

void* ReadFileToMemory( const char* path, int* size )
{
	void* data = 0;
	FILE* fp = fopen( path, "rb" );
	int sizeNum = 0;

	if ( fp )
	{
		fseek( fp, 0, SEEK_END );
		sizeNum = ftell( fp );
		fseek( fp, 0, SEEK_SET );
		data = malloc( sizeNum + 1 );
		fread( data, sizeNum, 1, fp );
		((char*)data)[ sizeNum ] = 0;
		fclose( fp );
	}

	if ( size ) *size = sizeNum;
	return data;
}

int ErrorFunc( lua_State* L )
{
	printf( "Lua error occurred: %s", lua_tostring( L, -1 ) );
	lua_pop( L, 1 ); // pop the error string
	return 0;
}

void StackDump( lua_State* L )
{
	int top = lua_gettop( L );
	printf( "\nLua Stack Dump:\n" );
	printf( "  Sizeof stack: %d\n", top );

	for(int i = 1; i <= top; ++i)
	{
		int type = lua_type(L,i);
		switch (type)
		{
		case LUA_TSTRING:  printf( "  %d: %s\n", i , lua_tostring(  L, i    ) ); break;
		case LUA_TBOOLEAN: printf( "  %d: %d\n", i , lua_toboolean( L, i    ) ); break;
		case LUA_TNUMBER:  printf( "  %d: %g\n", i , lua_tonumber(  L, i    ) ); break;
		default:           printf( "  %d: %s\n", i , lua_typename(  L, type ) ); break;
		}
	}

	printf( "  -->End stack dump.\n" );
}

void Dofile( lua_State* L, const char* name )
{
	if ( luaL_dofile( L, name ) )
		ErrorFunc( L );
}

void Tick( lua_State* L )
{
	lua_pushcfunction( L , ErrorFunc ); // 1
	lua_getglobal( L, "Tick" ); // 2
	int arg_count = 0;
	int error_func_index = -((int)(arg_count + 2));
	int ret = lua_pcall( L, arg_count, 1, error_func_index );
	lua_remove( L, lua_gettop( L ) - 1 ); // pop error function or error data
	lua_pop( L, 1 ); // pop final nil
}

int main( )
{
	glfwSetErrorCallback( ErrorCB );

	if ( !glfwInit( ) )
		return 1;

	glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 2 );
	glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 0 );

	window = glfwCreateWindow( 640, 480, "pook", NULL, NULL );
	Reshape( window, 640, 480 );

	if ( !window )
	{
		glfwTerminate( );
		return 1;
	}

	glfwSetKeyCallback( window, KeyCB );
	glfwSetFramebufferSizeCallback( window, Reshape );

	glfwMakeContextCurrent( window );
	gladLoadGLLoader( (GLADloadproc)glfwGetProcAddress );
	glfwSwapInterval( 1 );

	void* ctx = tgMakeCtx( 32 );

	glEnable( GL_CULL_FACE );
	glEnable( GL_DEPTH_TEST );
	glCullFace( GL_BACK );
	glFrontFace( GL_CCW );

	tgVertexData vd;
	tgMakeVertexData( &vd, 3, sizeof( Vertex ), GL_TRIANGLES, GL_STATIC_DRAW );
	tgAddAttribute( &vd, "a_pos", 3, TG_FLOAT, TG_OFFSET_OF( Vertex, position ) );
	tgAddAttribute( &vd, "a_col", 3, TG_FLOAT, TG_OFFSET_OF( Vertex, color ) );
	tgAddAttribute( &vd, "a_normal", 3, TG_FLOAT, TG_OFFSET_OF( Vertex, normal ) );

	tgRenderable r;
	tgShader simple;
	tgMakeRenderable( &r, &vd );
	char* vs = (char*)ReadFileToMemory( "simple.vs", 0 );
	char* ps = (char*)ReadFileToMemory( "simple.ps", 0 );
	TG_ASSERT( vs );
	TG_ASSERT( ps );
	tgLoadShader( &simple, vs, ps );
	free( vs );
	free( ps );
	tgSetShader( &r, &simple );

	Vertex verts[ 3 ];
	tgDrawCall call;
	call.texture_count = 0;
	call.r = &r;
	call.verts = verts;
	call.vert_count = 3;
	Vertex* v = (Vertex*)call.verts;
	v[ 0 ].position = V3( 0, 1, 0 );
	v[ 1 ].position = V3( -1, -1, 0 );
	v[ 2 ].position = V3( 1, -1, 0 );
	v3 n = norm( cross( sub( v[ 2 ].position, v[ 0 ].position ), sub( v[ 2 ].position, v[ 1 ].position ) ) );
	for ( int i = 0; i < 3; ++i )
	{
		v[ i ].normal = V3( 0, 1.0f, 0 );
		v[ i ].color = V3( 0.1f, 0.4f, 0.8f );
		v[ i ].normal = n;
	}

	float cam[ 16 ];
	LookAt( cam, V3( 0, 0, 5 ), V3( 0, 0, 0 ), V3( 0, 1, 0 ) );

	float mvp[ 16 ];
	m4Mul( projection, cam, mvp );

	tgSetActiveShader( &simple );
	tgSendMatrix( &simple, "u_mvp", mvp );
	tgDeactivateShader( );

	// init lua
	L = luaL_newstate( );
	luaL_openlibs( L );
	Dofile( L, "tick.lua" );

	glClearColor( 1.0f, 1.0f, 1.0f, 1.0f );
	while ( !glfwWindowShouldClose( window ) )
	{
		glfwPollEvents( );
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

		// WORKING HERE
		// setup dt timer
		// store renders in array, make lookup by string name
		// make a push buffer for triangles
		// bind PushTri to lua
		// bind PushDrawCall to lua
		// start doing some gfx from lua

		Tick( L );
		tgPushDrawCall( ctx, call );

		tgFlush( ctx, PookSwapBuffers );
		TG_PRINT_GL_ERRORS( );
	}

	tgFreeCtx( ctx );
	glfwDestroyWindow( window );
	glfwTerminate( );
	return 0;
}
