/// Vertex helper library by Oakleaff

include( "VertexFunctions" );
require( "Vectors" );

global._nx = 0;
global._ny = 0;
global._nz = 1;

globalvar VERTEXINDEX;
VERTEXINDEX = 0;

/// @description vformat_init();
function vformat_init() {
	// Init vertex buffer format 

	// Define vertex buffer format - ( x, y, z, nx, ny, nz, tx, ty, col, alpha )
	globalvar VERTEXFORMAT;

	vertex_format_begin();
		vertex_format_add_position_3d();
		vertex_format_add_normal();
	
		vertex_format_add_texcoord();
		vertex_format_add_colour();
	
	VERTEXFORMAT = vertex_format_end();
	
	
	log( "VERTEXFORMAT: " + string( VERTEXFORMAT ));
	
	// // Define vertex buffer format VERTEXFORMAT_SHATTER - ( x, y, z, nx, ny, nz, tx, ty, col, alpha, cx, cy, cz )
	globalvar VERTEXFORMAT_SHATTER; 

	vertex_format_begin();
		vertex_format_add_position_3d();
		vertex_format_add_normal();
	
		vertex_format_add_texcoord();
		vertex_format_add_colour();
		vertex_format_add_custom( vertex_type_float3, vertex_usage_texcoord ); // Center of triangle
	
	VERTEXFORMAT_SHATTER = vertex_format_end();
	
	// Define vertex buffer format VERTEXFORMAT_WEIGHT - ( x, y, z, nx, ny, nz, tx, ty, col, alpha, w1, w2, w3, w4, b1, b2, b3, b4 )
	globalvar VERTEXFORMAT_WEIGHT; 

	vertex_format_begin();
		vertex_format_add_position_3d();
		vertex_format_add_normal();
	
		vertex_format_add_texcoord();
		vertex_format_add_colour();
		
		vertex_format_add_custom( vertex_type_float4, vertex_usage_texcoord ); // Blend weights
		vertex_format_add_custom( vertex_type_float4, vertex_usage_texcoord ); // Blend indices
	
	VERTEXFORMAT_WEIGHT = vertex_format_end();


	// Vertex format byte size
	// 32bit signed floats = 4 bytes per number
	// x y z		= 3 * 4
	// nx ny nz		= 3 * 4
	// r g b a		= 4 * 1
	// u v			= 2 * 4
	globalvar VERTEXFORMAT_BYTE_SIZE;
	VERTEXFORMAT_BYTE_SIZE = 3 * 4 + 3 * 4 + 4 * 1 + 2 * 4;
}
vformat_init();


/// @function Vertex
/// @param x
/// @param y
/// @param z
/// @param nx
/// @param ny
/// @param nz
/// @param tx
/// @param ty
/// @param colour
/// @param alpha
function Vertex( _x = 0, _y = 0, _z = 0, _nx = 0, _ny = 0, _nz = 1, _tx = 0, _ty = 0, _col = c_white, _alpha = 1 ) constructor {
	
	x = _x;
	y = _y;
	z = _z;
	
	nx = _nx;
	ny = _ny;
	nz = _nz;
	
	tx = _tx;
	ty = _ty;
	
	colour	= _col;
	alpha	= _alpha;
	
	red		= colour_get_red( colour );
	green	= colour_get_green( colour );
	blue	= colour_get_blue( colour );
	
	index = VERTEXINDEX ++;
	
	// Init vertex weight data - up to 4 bones per vertex
	b1 = 0;
	w1 = 0;
	b2 = 0;
	w2 = 0;
	b3 = 0;
	w3 = 0;
	b4 = 0;
	w4 = 0;
	
	triangleList = [];
	
	/// @function Scale( _scale )
	static Scale = function( _scale ) {
		
		x *= _scale;
		y *= _scale;
		z *= _scale;
	
	}
	
	/// @function Spherize()
	static Spherize = function() {
		
		var vec = new Vector3( x, y, z );
		var len = vec.Magnitude();
		vec.Normalize();
		
		x = vec.x;
		y = vec.y;
		z = vec.z;
		
		nx = vec.x;
		ny = vec.y;
		nz = vec.z;
	
	}
	
	/// @function SetFromVector( vec )
	static SetFromVector = function( vec ) {
		x = vec.x;
		y = vec.y;
		z = vec.z;
	}
	
	/// @function Transform( matrix )
	static Transform = function( matrix ) {
		
		var pos = matrix_transform_vertex( matrix, x, y, z );
		x = pos[0];
		y = pos[1];
		z = pos[2];
		
		var mat = [];
		array_copy( mat, 0, matrix, 0, 16 );
		mat[12]	= 0.0;
		mat[13]	= 0.0;
		mat[14]	= 0.0;
		var normal	= matrix_transform_vertex( mat, nx, ny, nz );
		
		nx = normal[0];
		ny = normal[1];
		nz = normal[2];
		
	}
	
	
	/// @function WriteToBuffer( buffer ) 
	static WriteToBuffer = function( buffer, format = VERTEXFORMAT ) {
		
		buffer_write( buffer, buffer_f32, x );
		buffer_write( buffer, buffer_f32, y );
		buffer_write( buffer, buffer_f32, z );
		buffer_write( buffer, buffer_f32, nx );
		buffer_write( buffer, buffer_f32, ny );
		buffer_write( buffer, buffer_f32, nz );
		
		buffer_write( buffer, buffer_f32, tx );
		buffer_write( buffer, buffer_f32, ty );

		buffer_write( buffer, buffer_u8,	colour_get_red( colour ));
		buffer_write( buffer, buffer_u8,	colour_get_green( colour ));
		buffer_write( buffer, buffer_u8,	colour_get_blue( colour ));
		buffer_write( buffer, buffer_u8,	alpha * 255 );
		
		// Blend indices
		if ( format == VERTEXFORMAT_WEIGHT ) {
			buffer_write( buffer, buffer_u8, b1 );
			buffer_write( buffer, buffer_u8, b2 );
			buffer_write( buffer, buffer_u8, b3 );
			buffer_write( buffer, buffer_u8, b4 );
		
			// Blend weights
			buffer_write( buffer, buffer_f32, w1 );
			buffer_write( buffer, buffer_f32, w2 );
			buffer_write( buffer, buffer_f32, w3 );
			buffer_write( buffer, buffer_f32, w4 );
		}
	}
	
	/// @function ReadFromBuffer( buffer ) 
	static ReadFromBuffer = function( buffer, format = VERTEXFORMAT ) {
		
		x	= buffer_read( buffer,	buffer_f32 );
		y	= buffer_read( buffer,	buffer_f32 );
		z	= buffer_read( buffer,	buffer_f32 );
		nx	= buffer_read( buffer,	buffer_f32 );
		ny	= buffer_read( buffer,	buffer_f32 );
		nz	= buffer_read( buffer,	buffer_f32 );
		
		tx	= buffer_read( buffer,	buffer_f32 );
		ty	= buffer_read( buffer,	buffer_f32 );

		red		= buffer_read( buffer, buffer_u8 );
		green	= buffer_read( buffer, buffer_u8 );
		blue	= buffer_read( buffer, buffer_u8 );
		alpha	= buffer_read( buffer, buffer_u8 ) / 255;
		
		colour	= make_colour_rgb( red, green, blue );
		
		// Blend indices
		if ( format == VERTEXFORMAT_WEIGHT ) {
			b1 = buffer_read( buffer, buffer_u8 );
			b2 = buffer_read( buffer, buffer_u8 );
			b3 = buffer_read( buffer, buffer_u8 );
			b4 = buffer_read( buffer, buffer_u8 );
		
			// Blend weights
			w1 = buffer_read( buffer, buffer_f32 );
			w2 = buffer_read( buffer, buffer_f32 );
			w3 = buffer_read( buffer, buffer_f32 );
			w4 = buffer_read( buffer, buffer_f32 );
		}
	}
	
	/// @function Clone() 
	static Clone = function( ) {
		
		return new Vertex( x, y, z, nx, ny, nz, tx, ty, colour, alpha );
	}
	
}


/// @function vertex_mix( v0, v1, value ) {
/// @param {Struct.Vertex}	v0
/// @param {Struct.Vertex}	v1
/// @param {Real}			value
function vertex_mix( v0, v1, value ) {
	
	var v = new Vertex();
	
	v.x = lerp( v0.x, v1.x, value );
	v.y = lerp( v0.y, v1.y, value );
	v.z = lerp( v0.z, v1.z, value );
	
	v.nx = lerp( v0.nx, v1.nx, value );
	v.ny = lerp( v0.ny, v1.ny, value );
	v.nz = lerp( v0.nz, v1.nz, value );
	
	v.tx = lerp( v0.tx, v1.tx, value );
	v.ty = lerp( v0.ty, v1.ty, value );
	
	v.colour	= merge_colour( v0.colour, v1.colour, value );
	v.red		= lerp( v0.red,		v1.red,		value );
	v.green		= lerp( v0.green,	v1.green,	value );
	v.blue		= lerp( v0.blue,	v1.blue,	value );
	v.alpha		= lerp( v0.alpha,	v1.alpha,	value );
	
	return v;
	
}

/// @function Triangle( v1, v2, v3 );
function Triangle( _vert1 = noone, _vert2 = noone, _vert3 = noone ) constructor {
	
	material = "matDefault";
	
	vert[0] = _vert1;
	vert[1] = _vert2;
	vert[2] = _vert3;

	edge[0] = new Edge( vert[0], vert[1] );
	edge[1] = new Edge( vert[1], vert[2] );
	edge[2] = new Edge( vert[2], vert[0] );
	
	/// @function WriteToBuffer( buffer ) 
	static WriteToBuffer = function( buffer ) {
		
		buffer_write( buffer, buffer_string, material );
		vert[0].WriteToBuffer( buffer );
		vert[1].WriteToBuffer( buffer );
		vert[2].WriteToBuffer( buffer );
		
	}
	
	/// @function ReadFromBuffer( buffer ) 
	static ReadFromBuffer = function( buffer ) {
		
		material = buffer_read( buffer, buffer_string );
		
		vert[0] = new Vertex();
		vert[1] = new Vertex();
		vert[2] = new Vertex();
	
		vert[0].ReadFromBuffer( buffer );
		vert[1].ReadFromBuffer( buffer );
		vert[2].ReadFromBuffer( buffer );
	}
	
	
	/// @function ScaleUvs()
	static ScaleUvs = function() {
		
		if ( material == "matNone" ) exit;
			
		var data = global.materialData[? material ] ?? global.materialData[? "matDefault"]; // Fall back to default material
			
		// Scale uv coords to fit given material
		vert[0].tx = lerp( data[0], data[2], vert[0].tx );
		vert[0].ty = lerp( data[1], data[3], vert[0].ty );
		vert[1].tx = lerp( data[0], data[2], vert[1].tx );
		vert[1].ty = lerp( data[1], data[3], vert[1].ty );
		vert[2].tx = lerp( data[0], data[2], vert[2].tx );
		vert[2].ty = lerp( data[1], data[3], vert[2].ty );
		
		
	}
	
}
	
/// @function Edge( v1, v2 );
function Edge( _vert1, _vert2 ) constructor {
	
	material = "matDefault";
	
	vert[0] = _vert1;
	vert[1] = _vert2;
	
	if ( !is_struct( vert[0] )) vert[0] = noone;
	if ( !is_struct( vert[1] )) vert[1] = noone;
	
	/// @function WriteToBuffer( buffer ) 
	static WriteToBuffer = function( buffer ) {
		
		buffer_write( buffer, buffer_string, material );
		vert[0].WriteToBuffer( buffer );
		vert[1].WriteToBuffer( buffer );
		
	}
	
	/// @function ReadFromBuffer( buffer ) 
	static ReadFromBuffer = function( buffer ) {
		
		material = buffer_read( buffer, buffer_string );
		
		vert[0] = new Vertex();
		vert[1] = new Vertex();
	
		vert[0].ReadFromBuffer( buffer );
		vert[1].ReadFromBuffer( buffer );
	}
	
}
	
	
/// @function vertex_end_freeze( vbuffer );
function vertex_end_freeze( vbuffer ) {
	
	vertex_end( vbuffer );
	vertex_freeze( vbuffer );
	
}


/// @description get_normal(x1, y1, z1, x2, y2, z2, x3, y3, z3);
/// @param x1
/// @param  y1
/// @param  z1
/// @param  x2
/// @param  y2
/// @param  z2
/// @param  x3
/// @param  y3
/// @param  z3
function get_normal( x1, y1, z1, x2, y2, z2, x3, y3, z3 ) {

	var ax = x2 - x1;
	var ay = y2 - y1;
	var az = z2 - z1;

	var bx = x3 - x1;
	var by = y3 - y1;
	var bz = z3 - z1;

	var nx = ay * bz - az * by;
	var ny = az * bx - ax * bz;
	var nz = ax * by - ay * bx;

	var l = sqrt( nx * nx + ny * ny + nz * nz );

	nx /= l;
	ny /= l;
	nz /= l;
	
	return new Vector3( nx, ny, nz );

}

/// @param buffer
/// @param  x
/// @param  y
/// @param  z
/// @param  nx
/// @param  ny
/// @param  nz
/// @param  tx
/// @param  ty
/// @param  col
/// @param  alpha
function vbuffer_add_normal_texture_colour( buff, _x, _y, _z, _nx, _ny, _nz, _tx, _ty, _col, _alpha ) {

	vertex_position_3d  ( buff, _x, _y, _z );
	vertex_normal       ( buff, _nx, _ny, _nz );
	
	vertex_texcoord     ( buff, _tx, _ty );
	vertex_colour       ( buff, _col, _alpha );

}

/// @param	buffer
/// @param  vertex
/// @param	format
function vbuffer_add_vertex( buff, vert, format = VERTEXFORMAT ) {

	vertex_position_3d  ( buff, vert.x, vert.y, vert.z );
	vertex_normal       ( buff, vert.nx, vert.ny, vert.nz );
	
	vertex_texcoord     ( buff, vert.tx, vert.ty );
	vertex_colour       ( buff, vert.colour, vert.alpha );
	
	if ( format == VERTEXFORMAT_WEIGHT ) {
		
		vertex_float4( buff, vert.b1, vert.b2, vert.b3, vert.b4 );
		vertex_float4( buff, vert.w1, vert.w2, vert.w3, vert.w4 );
		
	}

}

/// @param buffer
/// @param  x1
/// @param  y1
/// @param  z1
/// @param  x2
/// @param  y2
/// @param  z2
/// @param  *col1
/// @param  *alpha1
/// @param  *col2
/// @param  *alpha2
/// @param  *nx
/// @param  *ny
/// @param  *nz
function vbuffer_add_line( buff, x1, y1, z1, x2, y2, z2, col1 = c_white, alpha1 = 1, col2 = c_white, alpha2 = 1, nx = 0, ny = 0, nz = 0 ) {

	var tx1 = 0;
	var ty1 = 0;

	var tx2 = 1;
	var ty2 = 1;

	vbuffer_add_normal_texture_colour( buff, x1, y1, z1, nx, ny, nz, tx1, ty1, col1, alpha1 );
	vbuffer_add_normal_texture_colour( buff, x2, y2, z2, nx, ny, nz, tx2, ty2, col2, alpha2 );
	
}

/// @function vbuffer_add_vertex_quad( vbuffer, v1, v2, v3, v4, normalize, tesselationLevel )
/// @param	buffer
/// @param  v1
/// @param  v2
/// @param  v3
/// @param  v4
/// @param	normal
/// @param	tesselation
function vbuffer_add_vertex_quad( buff, v1, v2, v3, v4, normal = false, tesselation = 0 ) {
	
	if ( tesselation == 0 ) {
		// Triangle 1
		vbuffer_add_vertex_triangle( buff, v1, v2, v3, normal );
	
		// Triangle 2
		vbuffer_add_vertex_triangle( buff, v1, v3, v4, normal );
		
		return;
	}
	
	// Tesselation
	var _w = power( 2, tesselation );
	var _v1, _v2, _v3, _v4, tx0, ty0, tx1, ty1;
	
	// Edge vertices
	var N, E, S, W;
	N = [];
	S = [];
	
	N[0] = v1;
	S[0] = v4;
	
	for ( var xx = 1; xx <= _w; xx ++ ) {
		
		// Lerp values for bilinear filtering
		tx0 = xx / _w;

		N[xx] = vertex_mix( v1, v2, tx0 );
		S[xx] = vertex_mix( v4, v3, tx0 );
	}
	
	for ( var xx = 0; xx < _w; xx ++ ) {
	for ( var yy = 0; yy < _w; yy ++ ) {
		
		// Lerp values - bilinear filtering
		ty0 = yy / _w;
		ty1 = ( yy + 1 ) / _w;
		
		// Update vertex values
		_v1 = vertex_mix( N[xx],		S[xx],		ty0 );
		_v2 = vertex_mix( N[xx + 1],	S[xx + 1],	ty0 );
		_v3 = vertex_mix( N[xx + 1],	S[xx + 1],	ty1 );
		_v4 = vertex_mix( N[xx],		S[xx],		ty1 );
		
		// Triangle 1
		vbuffer_add_vertex_triangle( buff, _v1, _v2, _v3, normal );
	
		// Triangle 2
		vbuffer_add_vertex_triangle( buff, _v1, _v3, _v4, normal );
		
		delete _v1;
		delete _v2;
		delete _v3;
		delete _v4;
		
	}}

	
}

/// @param buffer
/// @param  v1
/// @param  v2
/// @param  v3
/// @param	normal
function vbuffer_add_vertex_triangle( buff, v1, v2, v3, normal = false ) {
	
	// Triangle 1
	var n = new Vector3( 0, 0, 1 );
	if ( normal ) {
		n = get_normal( v1.x, v1.y, v1.z, v2.x, v2.y, v2.z, v3.x, v3.y, v3.z );
		
		vbuffer_add_normal_texture_colour( buff, v1.x, v1.y, v1.z, n.x, n.y, n.z, v1.tx, v1.ty, v1.colour, v1.alpha );
		vbuffer_add_normal_texture_colour( buff, v2.x, v2.y, v2.z, n.x, n.y, n.z, v2.tx, v2.ty, v2.colour, v2.alpha );
		vbuffer_add_normal_texture_colour( buff, v3.x, v3.y, v3.z, n.x, n.y, n.z, v3.tx, v3.ty, v3.colour, v3.alpha );
	}
	else {
		vbuffer_add_normal_texture_colour( buff, v1.x, v1.y, v1.z, v1.nx, v1.ny, v1.nz, v1.tx, v1.ty, v1.colour, v1.alpha );
		vbuffer_add_normal_texture_colour( buff, v2.x, v2.y, v2.z, v2.nx, v2.ny, v2.nz, v2.tx, v2.ty, v2.colour, v2.alpha );
		vbuffer_add_normal_texture_colour( buff, v3.x, v3.y, v3.z, v3.nx, v3.ny, v3.nz, v3.tx, v3.ty, v3.colour, v3.alpha );
	}
}

/// @param	buffer
/// @param  x1
/// @param  y1
/// @param  z1
/// @param  x2
/// @param  y2
/// @param  z2
/// @param  x3
/// @param  y3
/// @param  z3
/// @param  x4
/// @param  y4
/// @param  z4
/// @param  tx1
/// @param  ty1
/// @param  tx2
/// @param  ty2
/// @param  *col1
/// @param  *alpha1
/// @param  *col2
/// @param  *alpha2
/// @param  *col3
/// @param  *alpha3
/// @param  *col4
/// @param  *alpha4
function vbuffer_add_quad() {
	var buff = argument[0];

	var i = 1;
	var x1 = argument[i++];
	var y1 = argument[i++];
	var z1 = argument[i++];

	var x2 = argument[i++];
	var y2 = argument[i++];
	var z2 = argument[i++];

	var x3 = argument[i++];
	var y3 = argument[i++];
	var z3 = argument[i++];

	var x4 = argument[i++];
	var y4 = argument[i++];
	var z4 = argument[i++];

	var tx1 = argument[i++];
	var ty1 = argument[i++];

	var tx2 = argument[i++];
	var ty2 = argument[i++];


	var col1    = c_white;
	var col2    = c_white;
	var col3    = c_white;
	var col4    = c_white;
	var alpha1  = 1;
	var alpha2  = 1;
	var alpha3  = 1;
	var alpha4  = 1;

	if (argument_count > i) { var col1      = argument[i++]; }
	if (argument_count > i) { var alpha1    = argument[i++]; }

	if (argument_count > i) { var col2      = argument[i++]; }
	if (argument_count > i) { var alpha2    = argument[i++]; }

	if (argument_count > i) { var col3      = argument[i++]; }
	if (argument_count > i) { var alpha3    = argument[i++]; }

	if (argument_count > i) { var col4      = argument[i++]; }
	if (argument_count > i) { var alpha4    = argument[i++]; }

	//var nx = 0; var ny = 0; var nz = 1;
	
	//get_normal( x1, y1, z1, x2, y2, z2, x3, y3, z3 );

	// Triangle 1
	var nx = global._nx; var ny = global._ny; var nz = global._nz;
	vbuffer_add_normal_texture_colour( buff, x1, y1, z1, nx, ny, nz, tx1, ty1, col1, alpha1 );
	vbuffer_add_normal_texture_colour( buff, x2, y2, z2, nx, ny, nz, tx2, ty1, col2, alpha2 );
	vbuffer_add_normal_texture_colour( buff, x3, y3, z3, nx, ny, nz, tx2, ty2, col3, alpha3 );

	// Triangle 2
	
	//get_normal( x1, y1, z1, x3, y3, z3, x4, y4, z4);
	
	vbuffer_add_normal_texture_colour( buff, x1, y1, z1, nx, ny, nz, tx1, ty1, col1, alpha1 );
	vbuffer_add_normal_texture_colour( buff, x3, y3, z3, nx, ny, nz, tx2, ty2, col3, alpha3 );
	vbuffer_add_normal_texture_colour( buff, x4, y4, z4, nx, ny, nz, tx1, ty2, col4, alpha4 );

}

// Combine vertex values from 2 meshes into one
// Returns a new vertex buffer
// If the meshes aren't vertex-count identical, you're gonna have a bad time (it'll fuck up the vertex indexing)
/// @function vbuffer_mesh_combine( mesh_to, mesh_from )
function vbuffer_mesh_combine( mesh1, mesh2 ) {
	
	/// @function buffer_read_vertex( buffer, vertex )
	/// @param buffer
	/// @param target_vertex
	static buffer_read_vertex = function( buffer, _vertex = -1 ) {
		
		var v = _vertex == -1 ? new Vertex() : _vertex;
		
		v.x			= buffer_read( buffer,	buffer_f32 );
		v.y			= buffer_read( buffer,	buffer_f32 );
		v.z			= buffer_read( buffer,	buffer_f32 );
		v.nx		= buffer_read( buffer,	buffer_f32 );
		v.ny		= buffer_read( buffer,	buffer_f32 );
		v.nz		= buffer_read( buffer,	buffer_f32 );
					
		v.tx		= buffer_read( buffer,	buffer_f32 );
		v.ty		= buffer_read( buffer,	buffer_f32 );

		v.red		= buffer_read( buffer,	buffer_u8 );
		v.green		= buffer_read( buffer,	buffer_u8 );
		v.blue		= buffer_read( buffer,	buffer_u8 );
		v.alpha		= buffer_read( buffer,	buffer_u8 ) / 255;
		
		v.colour	= make_colour_rgb( v.red, v.green, v.blue );
		
		return v;
		
	}
	
	
	// Target buffer (to)
	var buff1 = buffer_create_from_vertex_buffer( mesh1, buffer_grow, 1 );
	
	// Source buffer (from)
	var buff2 = buffer_create_from_vertex_buffer( mesh2, buffer_grow, 1 );
	
	
	// Go to buffer start
	buffer_seek( buff1, buffer_seek_start, 0 );
	buffer_seek( buff2, buffer_seek_start, 0 );
	
	
	// Init "virtual vertices"
	var v1 = new Vertex();
	var v2 = new Vertex();
	
	// Calculate vertex count from buffer sizes
	var vertexBytes = VERTEXFORMAT_BYTE_SIZE;
	var verts1		= buffer_get_size( buff1 ) / vertexBytes;
	var verts2		= buffer_get_size( buff2 ) / vertexBytes;
	var verts		= min( verts1, verts2 );
	
	// Create new mesh to return
	var mesh = vertex_create_buffer();
	vertex_begin( mesh, VERTEXFORMAT );

	// Loop through buffer, read buffer data into vertices
	var i;
	for ( i = 0; i < verts; i ++ ) {
		
		// Read vertex data from buffer
		buffer_read_vertex( buff1, v1 );
		buffer_read_vertex( buff2, v2 );

		// Overwrite values between target & source vertices
		// v2 pos --> v1 normals
		v1.nx = v2.x;
		v1.ny = v2.y;
		v1.nz = v2.z;
		
		
		// Add vertex to new mesh
		vbuffer_add_vertex( mesh, v1 );
	}
	
	
	vertex_end_freeze( mesh );
	
	// Cleanup
	buffer_delete( buff1 );
	buffer_delete( buff2 );
	
	
	return mesh;
	
}

/// @function verts_set_uvs( v1, v2, v3, v4, uvs, flip_x, flip_y  )
function verts_set_uvs( v1, v2, v3, v4, uvs, flip_x = false, flip_y = false ) {
	
	v1.tx = flip_x ? uvs[0] : uvs[2];	
	v1.ty = flip_y ? uvs[1] : uvs[3];	
	v2.tx = flip_x ? uvs[2] : uvs[0];	
	v2.ty = flip_y ? uvs[1] : uvs[3];	
	v3.tx = flip_x ? uvs[2] : uvs[0];	
	v3.ty = flip_y ? uvs[3] : uvs[1];	
	v4.tx = flip_x ? uvs[0] : uvs[2];	
	v4.ty = flip_y ? uvs[3] : uvs[1];	
	
}

/// @function vert_set_uv( v1, uv  )
function vert_set_uv( v1, uv  ) {
	v1.tx = uv[0];
	v1.ty = uv[1];
}

/// @function verts_set_normals( normal, v1, v2, v3, v4... )
/// @param {Struct.Vector3|Array<Any> } normal_and_lerp_value
/// @param {Struct.Vertex} v1...vX
function verts_set_normals( ) {
	
	var normal = argument[0];
	var val = 0;
	
	if ( is_array( normal )) {
		val		= normal[1];
		normal	= normal[0];
	}
	
	var vert, i;
	
	for ( i = 1; i < argument_count; i ++ ) {
		
		vert = argument[ i ];
		vert.nx = val > 0 ? lerp( vert.nx, normal.x, val ) : normal.x;
		vert.ny = val > 0 ? lerp( vert.ny, normal.y, val ) : normal.y;
		vert.nz = val > 0 ? lerp( vert.nz, normal.z, val ) : normal.z;
	}
}

/// @function verts_normalize_normals( v1, v2, v3, v4... )
/// @param {Struct.Vertex} v1...vX
function verts_normalize_normals( ) {
	
	var vert, i, l;
	
	for ( i = 0; i < argument_count; i ++ ) {
		
		vert = argument[ i ];
		
		l = sqrt( vert.nx * vert.nx + vert.ny * vert.ny + vert.nz * vert.nz );
		
		vert.nx /= l;
		vert.ny /= l;
		vert.nz /= l;
	}
}

/// @function verts_set_colours( col, v1, v2, v3, v4... )
function verts_set_colours( ) {
	
	var col = argument[0];
	var vert, i;
	
	for ( i = 1; i < argument_count; i ++ ) {
		
		vert = argument[ i ];
		vert.colour = col;
		vert.red	= colour_get_red( col );
		vert.green	= colour_get_green( col );
		vert.blue	= colour_get_blue( col );
	}
}

/// @function verts_set_alpha( alpha, v1, v2, v3, v4... )
function verts_set_alpha( ) {
	
	var alpha = argument[0];
	var vert, i;
	
	for ( i = 1; i < argument_count; i ++ ) {
		
		vert = argument[ i ];
		vert.alpha = alpha;
	}
}