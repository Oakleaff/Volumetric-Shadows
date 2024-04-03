/// Macros
#macro GAME_NAME		"Game name"
#macro VERSION			"v0.9"

#macro log	show_debug_message

global.game_speed = 60;

#macro	GAME_SPEED		global.game_speed

#macro	METER	10

#macro ignore if ( true ) {} else

#macro	INHERIT				event_inherited();

enum TAG		{ None = 0, Player = 1, NPC = 2, Enemy = 4, Item = 8, World = 16, All = 255 };
enum MASK		{ None = 0, World = 1, Enemy = 2, Player = 4 };


global.texPageWidth		= 1.0 / texture_get_texel_width( sprite_get_texture( texWhite, 0 ));
global.texPageHeight	= 1.0 / texture_get_texel_width( sprite_get_texture( texWhite, 0 ));

global.__z = 0;
global.physEngineEnabled = false;

globalvar DELTA;
DELTA = 1 / GAME_SPEED;

global.loadState = [];

// Include && require
/// @function functions_init();
function functions_init() { 
	global.functionMap	= ds_map_create();
	global.functionName = "";
}
functions_init();

/// @function include( str )
function include( str ) { 
	
	if ( !variable_global_exists( "functionMap" )) functions_init();
	
	global.functionMap[? str]	= true
	global.functionName			= str;
	log( "Included " + str );
};

/// @function require( str )
function require( str ) {
	
	var			val = global.functionMap[? str] ?? false;			// Check if the library has already been loaded
	if ( !val ) val = script_exists( asset_get_index( str ));		// If not, check if the script exists in the project
	
	if ( !val ) show_message( str + " required (" + global.functionName + ")" );
	
	return val;
};

