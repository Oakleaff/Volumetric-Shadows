/// Macros
#macro log	show_debug_message

#macro	METER	10

#macro ignore if ( true ) {} else

#macro	INHERIT				event_inherited()


global.__z = 0;


globalvar DELTA;
DELTA = 1 / 60;

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
}

/// @function require( str )
function require( str ) {
	
	var			val = global.functionMap[? str] ?? false;			// Check if the library has already been loaded
	if ( !val ) val = script_exists( asset_get_index( str ));		// If not, check if the script exists in the project
	
	if ( !val ) show_message( str + " required (" + global.functionName + ")" );
	
	return val;
}

