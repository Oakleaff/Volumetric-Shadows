/// @description

globalvar Assets;
Assets = id;

#region Custom Meshes

	var tex = sprite_get_texture( texWhite, 0 );

	#region Spheres
	
		for ( var i = 0; i <= 2; i ++ ) {
	
			Assets.sphere[i] = {};
	
			Assets.sphere[i].mesh		= vertex_create_buffer();
			Assets.sphere[i].mesh2		= vertex_create_buffer();

			vertex_begin( Assets.sphere[i].mesh,		VERTEXFORMAT );
			vertex_begin( Assets.sphere[i].mesh2,		VERTEXFORMAT );

				vbuffer_add_icosphere( Assets.sphere[i].mesh,		i, true );
				vbuffer_add_icosphere( Assets.sphere[i].mesh2,		i, false );
				
			vertex_end_freeze( Assets.sphere[i].mesh );
			vertex_end_freeze( Assets.sphere[i].mesh2 );
			
			Assets.sphere[i].texture	= tex;
			Assets.sphere[i].texture_uv = texture_get_uv_array( Assets.sphere[i].texture );
		}
		
	#endregion


	#region Cubes
	
		Assets.cube = {};
		
		Assets.cube.mesh = vertex_create_buffer();
		
		var a0 = new Vertex( -1, -1, -1 );
		var a1 = new Vertex(  1, -1, -1 );
		var a2 = new Vertex(  1,  1, -1 );
		var a3 = new Vertex( -1,  1, -1 );
		var b0 = new Vertex( -1, -1,  1 );
		var b1 = new Vertex(  1, -1,  1 );
		var b2 = new Vertex(  1,  1,  1 );
		var b3 = new Vertex( -1,  1,  1 );
		
		
		vertex_begin( Assets.cube.mesh, VERTEXFORMAT );
		
			vbuffer_add_vertex_quad( Assets.cube.mesh, a0, a3, a2, a1, true );
			vbuffer_add_vertex_quad( Assets.cube.mesh, a0, a1, b1, b0, true );
			vbuffer_add_vertex_quad( Assets.cube.mesh, a1, a2, b2, b1, true );
			vbuffer_add_vertex_quad( Assets.cube.mesh, a2, a3, b3, b2, true );
			vbuffer_add_vertex_quad( Assets.cube.mesh, a3, a0, b0, b3, true );
			vbuffer_add_vertex_quad( Assets.cube.mesh, b0, b1, b2, b3, true );
			
		vertex_end_freeze( Assets.cube.mesh );
	
	#endregion
	
	
#endregion

global.loadState[ AssetLoader ] = true;