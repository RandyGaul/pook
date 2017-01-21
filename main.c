
#include <glad/glad.h>
#include <glfw/glfw_config.h>
#include <glfw/glfw3.h>

#define TINYGL_IMPL
#include "tinygl.h"

#define TT_IMPLEMENTATION
#include "tinytime.h"

#if defined(__APPLE__)
	#include <lua.h>
	#include <lualib.h>
	#include <lauxlib.h>
#else
	#include "lua\lua.h"
	#include "lua\lualib.h"
	#include "lua\lauxlib.h"
#endif

#include <stdio.h>
#include <float.h>

GLFWwindow* window;

// Same MVP being used for every single object for now.
float projection[ 16 ];
float mvp[ 16 ];
float cam[ 16 ];
tgShader simple;
struct Vertex;

lua_State* L;

void ErrorCB( int error, const char* description )
{
	fprintf( stderr, "Error: %s\n", description );
}

void pcall_setup( const char* func_name );
void pcall_do( int arg_count, int ret_value_count );
void HandleMouseMovement( lua_State* L, float x, float y );
void UpdateMvp();
void m4Mul( float* a, float* b, float* c );

void KeyCB( GLFWwindow* window, int key, int scancode, int action, int mods )
{
	if ( key == GLFW_KEY_ESCAPE && action == GLFW_PRESS )
		glfwSetWindowShouldClose( window, GLFW_TRUE );

	pcall_setup( "SetKey" );
	lua_pushnumber( L, (lua_Number)key );
	lua_pushnumber( L, (lua_Number)action );
	pcall_do( 2, 1 );
}

void MouseCB(GLFWwindow* window, double x, double y)
{
	HandleMouseMovement( L, (float)x, (float)y );
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

	// I think this is crashing bc cam target isn't far at all, doesn't matter though
	// TG_ASSERT( absf( len( top ) - 1.0f ) < FLT_EPSILON );

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
	m[ 10 ] = -front.z;
	m[ 11 ] = 0;

	v3 x = V3( m[ 0 ], m[ 4 ], m[ 8 ] );
	v3 y = V3( m[ 0 + 1 ], m[ 4 + 1 ], m[ 8 + 1 ] );
	v3 z = V3( m[ 0 + 2 ], m[ 4 + 2 ], m[ 8 + 2 ] );

	m[ 12 ] = -dot( x, eye );
	m[ 13 ] = -dot( y, eye );
	m[ 14 ] = -dot( z, eye );
	m[ 15 ] = 1.0f;
}

int UpdateCam( lua_State *L )
{
	float x = (float)luaL_checknumber(L, -3);
	float y = (float)luaL_checknumber(L, -2);
	float z = (float)luaL_checknumber(L, -1);
	lua_settop(L, 0);

	v3 eye = V3(5, 0, 0); // send this in from lua later
	LookAt(cam, eye, add( eye, V3( x, y, z ) ), V3(0, 1, 0));
	UpdateMvp();
	return 0;
}

void UpdateMvp()
{
	m4Mul(projection, cam, mvp);
	tgSetActiveShader( &simple );
	tgSendMatrix( &simple, "u_mvp", mvp );
	tgDeactivateShader( );
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

void ErrorBox( const char *exp, const char *file, int line, const char *msg, ... )
{
	char buffer[ 2048 ];

	// print out the file and line in visual studio format so the error can be
	// double clicked in the output window file(line) : error
	int offset = sprintf( buffer, "%s(%d) : ", file, line );
	if( msg )
	{
		va_list args;
		va_start(args, msg);
		vsnprintf( buffer + offset, 2048, msg, args );
		vfprintf( stderr, msg, args );
		va_end(args);
	}
	else strcpy( buffer + offset, "No Error Message" );

	fprintf( stderr, "%s\n", buffer );
	MessageBoxA( 0, buffer, 0, 0 );
}

#define MSG_BOX( msg, ... ) \
	do \
	{ \
		ErrorBox( NULL, __FILE__, __LINE__, msg, __VA_ARGS__ ); \
	} while( 0 )

#define ERROR_IF( condition, msg, ... ) \
	do \
	{ \
		if ( condition ) \
		{ \
			MSG_BOX( msg, __VA_ARGS__ ); \
		} \
	} while ( 0 )

#define LUA_ERROR_IF( L, condition, msg, ... ) \
	do \
	{ \
		if ( condition ) \
		{ \
			StackDump( L ); \
			MSG_BOX( msg, __VA_ARGS__ ); \
		} \
	} while ( 0 )

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
		case LUA_TSTRING:  printf( "  %d: \"%s\"\n", i , lua_tostring(  L, i    ) ); break;
		case LUA_TBOOLEAN: printf( "  %d: %d\n",     i , lua_toboolean( L, i    ) ); break;
		case LUA_TNUMBER:  printf( "  %d: %g\n",     i , lua_tonumber(  L, i    ) ); break;
		default:           printf( "  %d: %s\n",     i , lua_typename(  L, type ) ); break;
		}
	}

	printf( "  -->End stack dump.\n" );
}

int ErrorFunc( lua_State* L )
{
	const char* err_str = lua_tostring( L, -1 );
	printf( "Lua error occurred: %s\n", err_str );
	lua_pop( L, 1 ); // pop the error string
	return 0;
}

void Dofile( lua_State* L, const char* name )
{
	if ( luaL_dofile( L, name ) )
		ErrorFunc( L );
}

void pcall_setup( const char* func_name )
{
	lua_pushcfunction( L , ErrorFunc ); // 1
	lua_getglobal( L, func_name ); // 2
}

void pcall_do( int arg_count, int ret_value_count )
{
	int error_func_index = -((int)(arg_count + 2));
	int ret = lua_pcall( L, arg_count, ret_value_count, error_func_index );

	if ( ret != 0 )
	{
		printf("you done fucked up son. %s\n", lua_tostring(L, -1));
	}

	lua_settop( L, 0 );
}

void Tick( lua_State* L, float time )
{
	pcall_setup( "Tick" );
	lua_pushnumber( L, (lua_Number)time );
	pcall_do( 1, 1 );
}

void MakeMeshes( lua_State* L )
{
	pcall_setup( "MakeMeshes" );
	pcall_do( 0, 1 );
}

void HandleMouseMovement( lua_State* L, float x, float y )
{
	pcall_setup( "handleMouseMovement" );
	lua_pushnumber(L, (lua_Number)x);
	lua_pushnumber(L, (lua_Number)y);
	pcall_do( 2, 0 );
}

typedef struct
{
	int vert_count;
	Vertex* verts;
} Mesh;

typedef struct
{
	tgRenderable r;
	int count;
	int capacity;
	Vertex* verts;
} DrawCall;

#define MAX_MESHES 1024
#define MAX_DRAW_CALLS 1024
typedef struct
{
	int temp_count;
	int temp_capacity;
	Vertex* temp_verts;

	int last_mesh;
	int mesh_count;
	const char* mesh_names[ MAX_MESHES ];
	Mesh meshes[ MAX_MESHES ];

	int last_render;
	int render_count;
	const char* render_names[ MAX_DRAW_CALLS ];
	DrawCall calls[ MAX_DRAW_CALLS ];
} Meshes;

Meshes meshes;

void InitMeshes( )
{
	meshes.temp_verts = (Vertex*)malloc( sizeof( Vertex ) * 1024 );
	meshes.temp_capacity = 1024;
}

void FreeMeshes( )
{
	free( meshes.temp_verts );
	for ( int i = 0; i < meshes.mesh_count; ++i )
	{
		free( (char*)meshes.mesh_names[ i ] );
		free( meshes.meshes[ i ].verts );
	}
	memset( &meshes, 0, sizeof( meshes ) );
}

int PushMesh( lua_State *L )
{
	LUA_ERROR_IF( L, lua_gettop( L ) != 1, "PushMesh expects 1 parameters, a string" );
	ERROR_IF( meshes.mesh_count >= MAX_MESHES, "Hit MAX_MESHES limit" );
	const char* name = luaL_checkstring( L, -1 );
	lua_settop( L, 0 );
	int i = meshes.mesh_count++;
	Mesh* mesh = meshes.meshes + i;
	mesh->vert_count = meshes.temp_count;
	int size = sizeof( Vertex ) * mesh->vert_count;
	mesh->verts = (Vertex*)malloc( size );
	memcpy( mesh->verts, meshes.temp_verts, size );
	meshes.mesh_names[ i ] = strdup( name );
	meshes.temp_count = 0;
	return 0;
}

void PushVert( Vertex v )
{
	if ( meshes.temp_count == meshes.temp_capacity )
	{
		int new_cap = meshes.temp_capacity * 2;
		Vertex* new_verts = (Vertex*)malloc( sizeof( Vertex ) * new_cap );
		memcpy( new_verts, meshes.temp_verts, sizeof( Vertex ) * meshes.temp_count );
		free( meshes.temp_verts );
		meshes.temp_capacity = new_cap;
		meshes.temp_verts = new_verts;
	}
	meshes.temp_verts[ meshes.temp_count++ ] = v;
}

int PushVert_internal( lua_State *L )
{
	LUA_ERROR_IF( L, lua_gettop( L ) != 9, "PushVert_internal expects 9 parameters, all floats" );
	float x = (float)luaL_checknumber( L, -9 );
	float y = (float)luaL_checknumber( L, -8 );
	float z = (float)luaL_checknumber( L, -7 );
	float cx = (float)luaL_checknumber( L, -6 );
	float cy = (float)luaL_checknumber( L, -5 );
	float cz = (float)luaL_checknumber( L, -4 );
	float nx = (float)luaL_checknumber( L, -3 );
	float ny = (float)luaL_checknumber( L, -2 );
	float nz = (float)luaL_checknumber( L, -1 );
	lua_settop( L, 0 );
	Vertex v;
	v.position = V3( x, y, z );
	v.color = V3( cx, cy, cz );
	v.normal = V3( nx, ny, nz );
	PushVert( v );
	return 0;
}

#define Register( L, func ) Register_internal( L, func, #func )
void Register_internal( lua_State *L, lua_CFunction func, const char* name )
{
	lua_pushcfunction( L, func );
	lua_setglobal( L, name );
}

void PushTransformedVert( Vertex v, DrawCall* call )
{
	if ( call->count == call->capacity )
	{
		int new_cap = call->capacity * 2;
		Vertex* new_verts = (Vertex*)malloc( sizeof( Vertex ) * new_cap );
		memcpy( new_verts, call->verts, sizeof( Vertex ) * call->count );
		free( call->verts );
		call->capacity = new_cap;
		call->verts = new_verts;
	}
	call->verts[ call->count++ ] = v;
}

int FindRender( const char* name )
{
	int index = meshes.last_render;
	int found = 0;

	if ( !strcmp( meshes.render_names[ index ], name ) ) found = 1;
	else
	{
		for ( int i = 0; i < meshes.render_count; ++i )
		{
			if ( !strcmp( meshes.render_names[ i ], name ) )
			{
				index = i;
				found = 1;
				break;
			}
		}
	}

	if ( !found ) ERROR_IF( 0, "SetRender could not find %s", name );
	meshes.last_render = index;
	return index;
}

int PushInstance( lua_State *L )
{
	LUA_ERROR_IF( L, lua_gettop( L ) != 5, "PushInstance expects 5 parameters, two strings and 3 floats" );
	const char* render_name = luaL_checkstring( L, -5 );
	const char* mesh_name = luaL_checkstring( L, -4 );
	float x = (float)luaL_checknumber( L, -3 );
	float y = (float)luaL_checknumber( L, -2 );
	float z = (float)luaL_checknumber( L, -1 );
	lua_settop( L, 0 );
	v3 p = V3( x, y, z );

	int index = meshes.last_mesh;
	int found = 0;

	if ( !strcmp( meshes.mesh_names[ index ], mesh_name ) ) found = 1;
	else
	{
		for ( int i = 0; i < meshes.mesh_count; ++i )
		{
			if ( !strcmp( meshes.mesh_names[ i ], mesh_name ) )
			{
				index = i;
				found = 1;
				break;
			}
		}
	}

	if ( !found )
	{
		ERROR_IF( 0, "SetRender could not find %s", mesh_name );
		return 0;
	}

	meshes.last_mesh = index;
	Mesh* mesh = meshes.meshes + index;
	DrawCall* call = meshes.calls + FindRender( render_name );

	for ( int i = 0; i < mesh->vert_count; ++i )
	{
		Vertex v = mesh->verts[ i ];
		v.position = add( v.position, p );
		PushTransformedVert( v, call );
	}

	return 0;
}

int Flush( lua_State *L )
{
	LUA_ERROR_IF( L, lua_gettop( L ) != 1, "SetRender expects 1 parameter, a string" );
	const char* name = luaL_checkstring( L, -1 );
	lua_settop( L, 0 );
	int call_index = FindRender( name );
	DrawCall* dc = meshes.calls + call_index;
	tgDrawCall call;
	call.texture_count = 0;
	call.r = &dc->r;
	call.verts = dc->verts;
	call.vert_count = dc->count;
	return 0;
}

void AddRender( tgRenderable* render, const char* name )
{
	ERROR_IF( meshes.render_count == MAX_DRAW_CALLS, "Hit MAX_RENDERS" );
	meshes.render_names[ meshes.render_count ] = name;
	DrawCall call;
	memset( &call, 0, sizeof( call ) );
	call.r = *render;
	call.capacity = 1024;
	call.verts = (Vertex*)malloc( sizeof( Vertex ) * 1024 );
	meshes.calls[ meshes.render_count++ ] = call;
}

void SetUpRenderable(uint32_t primitiveType, const char* name, const char* vsPath, const char* psPath)
{
	tgVertexData vd;
	tgMakeVertexData( &vd, 1024 * 1024, sizeof( Vertex ), primitiveType, GL_DYNAMIC_DRAW );
	tgAddAttribute( &vd, "a_pos", 3, TG_FLOAT, TG_OFFSET_OF( Vertex, position ) );
	tgAddAttribute( &vd, "a_col", 3, TG_FLOAT, TG_OFFSET_OF( Vertex, color ) );
	tgAddAttribute( &vd, "a_normal", 3, TG_FLOAT, TG_OFFSET_OF( Vertex, normal ) );

	tgRenderable r;
	tgMakeRenderable( &r, &vd );
	char* vs = (char*)ReadFileToMemory( vsPath, 0 );
	char* ps = (char*)ReadFileToMemory( psPath, 0 );
	TG_ASSERT( vs );
	TG_ASSERT( ps );
	tgLoadShader( &simple, vs, ps );
	free( vs );
	free( ps );
	tgSetShader( &r, &simple );
	AddRender( &r, name );
}

int main( )
{
	glfwSetErrorCallback( ErrorCB );

	if ( !glfwInit( ) )
		return 1;

	glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 2 );
	glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 0 );

	window = glfwCreateWindow( 1200, 800, "pook", NULL, NULL );
	Reshape( window, 1200, 800 );

	if ( !window )
	{
		glfwTerminate( );
		return 1;
	}

	glfwSetKeyCallback( window, KeyCB );
	glfwSetCursorPosCallback( window, MouseCB );
	glfwSetFramebufferSizeCallback( window, Reshape );

	glfwMakeContextCurrent( window );
	gladLoadGLLoader( (GLADloadproc)glfwGetProcAddress );
	glfwSwapInterval( 1 );

	void* ctx = tgMakeCtx( 32 );

	glEnable( GL_CULL_FACE );
	glEnable( GL_DEPTH_TEST );
	glCullFace( GL_BACK );
	glFrontFace( GL_CCW );

	SetUpRenderable(GL_TRIANGLES, "simple", "assets/shaders/simple.vs", "assets/shaders/simple.ps");
	SetUpRenderable(GL_QUADS, "quads", "assets/shaders/simple.vs", "assets/shaders/simple.ps");

	LookAt( cam, V3( 0, 0, 5 ), V3( 0, 0, 0 ), V3( 0, 1, 0 ) );

	m4Mul( projection, cam, mvp );

	UpdateMvp();

	// init lua
	L = luaL_newstate( );
	luaL_openlibs( L );
	Dofile( L, "src/core/init.lua" );
	Register( L, PushMesh );
	Register( L, PushVert_internal );
	Register( L, PushInstance );
	Register( L, UpdateCam );
	Register( L, Flush );
	InitMeshes( );
	MakeMeshes( L );

	glClearColor( 1.0f, 1.0f, 1.0f, 1.0f );
	while ( !glfwWindowShouldClose( window ) )
	{
		glfwPollEvents( );
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

		float dt = ttTime( );
		Tick( L, dt );

		for ( int i = 0; i < meshes.render_count; ++i )
		{
			DrawCall* dc = meshes.calls + i;
			if ( dc->count )
			{
				tgDrawCall call;
				call.r = &dc->r;
				call.texture_count = 0;
				call.verts = dc->verts;
				call.vert_count = dc->count;
				call.verts = dc->verts;
				tgPushDrawCall( ctx, call );
				dc->count = 0;
			}
		}

		tgFlush( ctx, PookSwapBuffers );
		TG_PRINT_GL_ERRORS( );
	}

	lua_close( L );
	FreeMeshes( );
	tgFreeCtx( ctx );
	glfwDestroyWindow( window );
	glfwTerminate( );
	return 0;
}
