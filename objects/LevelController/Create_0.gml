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
	
	Level.lightDirection	= new Vector3( 1, 1, -0.5 ).Normalized();
	
	Level.texture		= sprite_get_texture( texGrid, 0 );
	Level.texture_uv	= texture_get_uv_array( Level.texture );
	Level.noiseTexture	= sprite_get_texture( texColourNoise, 0 );
		
	// Lighting, ambient & sky colours are defined via variable definitions!
		

#endregion
	

// Create shapes
repeat ( 20 ) {
	instance_create( 0, 0, oShape );
}

var _shape = instance_create_3d( 0, 0, 0, oShape );
_shape.transformMatrix = matrix_build( 0, 0, -METER * 10, 0, 0, 0, METER * 50, METER * 50, 5 );


global.loadState[ LevelController ] = true;