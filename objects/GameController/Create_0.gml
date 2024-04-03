/// @description Global game controller

random_set_seed( 0 );

#region Init systems

	debug_init();
	shaders_init();
	
#endregion

globalvar Game;
Game = id;

// Define load states
global.loadState[ AssetLoader ]			= false;
global.loadState[ CameraController ]	= false;
global.loadState[ LevelController ]		= false;

// Create controllers
instance_create( 0, 0, AssetLoader );
instance_create( 0, 0, LevelController );
instance_create( 0, 0, CameraController );
instance_create( 0, 0, DrawController );


	






