/// @description 

globalvar Level;
Level = id;

z = 0;

castShadows = true;

#region World

	Level.origin	= new Vector3();
	Level.up		= new Vector3( 0.0, 0.0, 1.0 );
	Level.right		= new Vector3( 0.0, 1.0, 0.0 );
	Level.forward	= new Vector3( 1.0, 0.0, 0.0 );
	
	Level.lightDirection	= new Vector3( 1, 1, -1 ).Normalized();
	
	Level.texture		= sprite_get_texture( texGrid, 0 );
	Level.texture_uv	= texture_get_uv_array( Level.texture );
	Level.noiseTexture	= sprite_get_texture( texColourNoise, 0 );
		
	// Lighting, ambient & sky colours are defined via variable definitions!
		

#endregion
	
#region Meshes

	var grid_size	= METER * 100;
	
	Level.mesh = vertex_create_buffer();
	
	var a0 = new Vertex( -grid_size, -grid_size, 0, 0, 0, 1, 0, 0, c_white, 1 );
	var a1 = new Vertex(  grid_size, -grid_size, 0, 0, 0, 1, 0, 0, c_white, 1 );
	var a2 = new Vertex(  grid_size,  grid_size, 0, 0, 0, 1, 0, 0, c_white, 1 );
	var a3 = new Vertex( -grid_size,  grid_size, 0, 0, 0, 1, 0, 0, c_white, 1 );

	vertex_begin( Level.mesh, VERTEXFORMAT );
		
		vbuffer_add_vertex_quad( Level.mesh, a0, a1, a2, a3 );
		
	vertex_end_freeze( Level.mesh );
	
	/// @function render()
	function render() {
		
		vertex_submit( Level.mesh, pr_trianglelist, Level.texture );
		
	}

#endregion


// Create shapes
repeat ( 10 ) {
	instance_create( 0, 0, oShape );
}


global.loadState[ LevelController ] = true;