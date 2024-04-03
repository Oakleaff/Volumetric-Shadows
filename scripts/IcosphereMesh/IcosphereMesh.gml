// Functions to add icospheres to vertex buffers

include( "IcosphereMesh" );
require( "Vectors" );
require( "Quaternions" );
require( "VertexFunctions" );

/// @function vbuffer_add_icosphere
/// @param vbuffer
/// @param resolution
/// @param smooth
/// @param x
/// @param y
/// @param z
/// @param size
/// @param rotation
/// @param colour
function vbuffer_add_icosphere( buff, resolution = 0, smooth = 0, x0 = 0, y0 = 0, z0 = 0, radius = 1, rotation = -1, colour = c_white  ) {

	if ( rotation <= 0 ) {
		rotation = new Quaternion();
	}

	// Generate icosphere mesh
	// Returns a list of triangles that make up the mesh
	var sphere = icosphere_generate( resolution, smooth, x0, y0, z0, radius, rotation, colour );
	
	vertexList		= sphere[0];
	triangleList	= sphere[1];
	vertexMap		= sphere[2];
	
	var uv = sprite_get_uvs( texWhite, 0 );
	var tx = avg( uv[0], uv[2] );
	var ty = avg( uv[1], uv[3] );
	
	// Create mesh triangles
	for ( var n = 0; n < ds_list_size( triangleList ); n ++ ) {
		
		var _triangle = triangleList[| n];
		var v1 = _triangle.vert[0];
		var v2 = _triangle.vert[1];
		var v3 = _triangle.vert[2];
		
		if ( !smooth ) { 
			
			var _nx = avg( v1.nx, v2.nx, v3.nx );
			var _ny = avg( v1.ny, v2.ny, v3.ny );
			var _nz = avg( v1.nz, v2.nz, v3.nz );
			
			vbuffer_add_normal_texture_colour( buff, v1.x, v1.y, v1.z, _nx, _ny, _nz, tx, ty, colour, 1 );
			vbuffer_add_normal_texture_colour( buff, v2.x, v2.y, v2.z, _nx, _ny, _nz, tx, ty, colour, 1 );
			vbuffer_add_normal_texture_colour( buff, v3.x, v3.y, v3.z, _nx, _ny, _nz, tx, ty, colour, 1 );
			
		}
		else {
			vbuffer_add_normal_texture_colour( buff, v1.x, v1.y, v1.z, v1.nx, v1.ny, v1.nz, tx, ty, colour, 1 );
			vbuffer_add_normal_texture_colour( buff, v2.x, v2.y, v2.z, v2.nx, v2.ny, v2.nz, tx, ty, colour, 1 );
			vbuffer_add_normal_texture_colour( buff, v3.x, v3.y, v3.z, v3.nx, v3.ny, v3.nz, tx, ty, colour, 1 );
		}
	}
		
	
	
	ds_list_destroy(	vertexList );
	ds_list_destroy(	triangleList );
	ds_map_destroy(		vertexMap );

}


/// @function icosphere_generate()
/// @param resolution
/// @param smooth
/// @param x
/// @param y
/// @param z
/// @param size
/// @param rotation
/// @param colour
function icosphere_generate( resolution = 0, smooth = 0, x0 = 0, y0 = 0, z0 = 0, radius = 1, rotation = -1, colour = c_white  ) {

	if ( rotation <= 0 ) {
		rotation = new Quaternion();
	}
	
	
	vertexList		= ds_list_create();
	triangleList	= ds_list_create();
	
	// Keep track of vertices so triangles can share vertices
	vertexMap		= ds_map_create();
	
	
	// Create vertices
	var i = 0;
	var t = ( 1.0 + sqrt( 5.0 )) / 2.0;
	
	var v0	= add_vertex( new Vertex(-1,  t,  0 ));
	var v1	= add_vertex( new Vertex( 1,  t,  0 ));
	var v2	= add_vertex( new Vertex(-1, -t,  0 ));
	var v3	= add_vertex( new Vertex( 1, -t,  0 ));
							 
	var v4	= add_vertex( new Vertex( 0, -1,  t ));
	var v5	= add_vertex( new Vertex( 0,  1,  t ));
	var v6	= add_vertex( new Vertex( 0, -1, -t ));
	var v7	= add_vertex( new Vertex( 0,  1, -t ));
							 
	var v8	= add_vertex( new Vertex( t,  0, -1 ));
	var v9	= add_vertex( new Vertex( t,  0,  1 ));
	var v10	= add_vertex( new Vertex(-t,  0, -1 ));
	var v11	= add_vertex( new Vertex(-t,  0,  1 ));
	
	
	// Add 20 base triangles
		
		// 5 faces around point 0
		add_triangle( v0, v11, v5);
        add_triangle( v0, v5, v1);
        add_triangle( v0, v1, v7);
        add_triangle( v0, v7, v10);
        add_triangle( v0, v10, v11);

        // 5 adjacent faces 
        add_triangle( v1, v5, v9);
        add_triangle( v5, v11, v4);
        add_triangle( v11, v10, v2);
        add_triangle( v10, v7, v6);
        add_triangle( v7, v1, v8);

        // 5 faces around point 3
        add_triangle( v3, v9, v4);
        add_triangle( v3, v4, v2);
        add_triangle( v3, v2, v6);
        add_triangle( v3, v6, v8);
        add_triangle( v3, v8, v9);

        // 5 adjacent faces 
        add_triangle( v4, v9, v5);
        add_triangle( v2, v4, v11);
        add_triangle( v6, v2, v10);
        add_triangle( v8, v6, v7);
        add_triangle( v9, v8, v1);
		
		
	// Refine triangles
	log( "Resolution: " + string( resolution ));
	
	if ( resolution > 0 ) {
		for ( var i = 0; i < resolution; i ++ ) {
		
			// Copy current triangleList into a temp list for processing
			var tempList = ds_list_create();
			ds_list_copy( tempList, triangleList );
			
			ds_list_clear( triangleList );
			
			// Loop through all triangles, break them up and add them to the (new) trianglelist
			for ( var n = 0; n < ds_list_size( tempList ); n ++ ) {
		
				// Get current triangle vertices
				var _triangle = tempList[| n];
				var v1 = _triangle.vert[0];
				var v2 = _triangle.vert[1];
				var v3 = _triangle.vert[2];
				
				// Calculate midpoints between vertices
				var a = get_middle_point( v1, v2 );
				var b = get_middle_point( v2, v3 );
				var c = get_middle_point( v3, v1 );
				
				a.Spherize();
				b.Spherize();
				c.Spherize();
			
				// Add new vertices to vertexList && spherize
				var a1 = add_vertex( a );
				var b1 = add_vertex( b );
				var c1 = add_vertex( c );
				
				// Add new triangles
				add_triangle( v1, a1, c1 );
				add_triangle( v2, b1, a1 );
				add_triangle( v3, c1, b1 );
				add_triangle( a1, b1, c1 );
			}
			
			log( "Trianglelist: " + string( ds_list_size( triangleList )));
			
			ds_list_destroy( tempList );
			tempList = -1;
		}
	}
	
			
	// Rotation
	if ( rotation != -1 ) {
		var matrix = quaternion_to_matrix( rotation );
		for ( var n = 0; n < ds_list_size( vertexList ); n ++ ) {
			vert = vertexList[| n];
			var pos = matrix_transform_vertex( matrix, vert.x, vert.y, vert.z );

			vert.x = pos[0];
			vert.y = pos[1];
			vert.z = pos[2];
			
			vert.Spherize();
			
		}
	}
	
	
	// Radius
	if ( radius != 1 ) {
		
		var checkList = ds_list_create();
		
		for ( var n = 0; n < ds_list_size( vertexList ); n ++ ) {
			vert = vertexList[| n];
			
			if ( ds_list_find_index( checkList, vert ) == -1 ) {
				vert.Scale( radius );
				ds_list_add( checkList, vert );
			}
		}
		
		ds_list_destroy( checkList );
	}
	

	
	// Position
	if ( x0 + y0 + z0 != 0 ) {
		for ( var n = 0; n < ds_list_size( vertexList ); n ++ ) {
			vert = vertexList[| n];
			
			vert.x += x0;
			vert.y += y0;
			vert.z += z0;
		}
	}

	// Return data
	return [ vertexList, triangleList, vertexMap ];
	
}
		

/// @function add_vertex
/// @param vertex
function add_vertex( vert ) {
	
	vert.Spherize();
	
	ds_list_add( vertexList, vert );
	
	return vert;
	//return ( ds_list_find_index( vertexList, vert ));
}


/// @function	add_triangle
/// @param		v1
/// @param		v2
/// @param		v3
function add_triangle( v1, v2, v3 ) {
	
	//var _v1 = vertexList[| v1];
	//var _v2 = vertexList[| v2];
	//var _v3 = vertexList[| v3];
	
	var _triangle = new Triangle( v1, v2, v3 );
	
	ds_list_add( triangleList, _triangle );
}


/// @function get_middle_point
/// @param vertex1
/// @param vertex2
function get_middle_point( v1, v2 ) {
	
	var xx = avg( v1.x, v2.x );
	var yy = avg( v1.y, v2.y );
	var zz = avg( v1.z, v2.z );
	
	// Check for an existing vertex...
	var i1, i2;
	
	if ( v1.index < v2.index ) { 
		i1 = v1.index;
		i2 = v2.index;
	}
	else {
		i1 = v2.index;
		i2 = v1.index;
	}
	
	var index_string = string( i1 ) + "." + string( i2 );
	
	// Find an existing vertex
	var point = ds_map_find_value( vertexMap, index_string );
	
	// Add new vertex
	if ( is_undefined( point )) {
		point = new Vertex( xx, yy, zz );
		point.Spherize();
		ds_map_add( vertexMap, index_string, point );
	}
	

	return ( point );
}

