// Shader helper library

include( "ShaderFunctions" );
require( "Vectors" );

// Init shader data
#macro	SHADER_COUNT	array_length( asset_get_ids( asset_shader ))

/// @function		shaders_init();
/// @description	Init shader handler uniforms as ds_maps for further use
function shaders_init() {
	
	log( "Shader init" );

	// Create a ds_map for each shader
	global._shaderMap = [];
	
	// Index all shaders
	for ( var i = 0; i < SHADER_COUNT; i ++ ) {
		
		var name = shader_get_name( i );
		if ( !shader_is_compiled( i )) log( "Shader " + name + " is not compiled" );
		
		log( name );
	
		global._shaderMap[i] = ds_map_create();
	}
	
}

global._renderTarget = [];
global._renderTarget[0] = application_surface;
global._renderTarget[1] = -1;
global._renderTarget[2] = -1;
global._renderTarget[3] = -1;
/// @function shader_set_ext( shader, target0, target1, target2, target3 )
function shader_set_ext( shader, target0 = global._renderTarget[0], target1 = global._renderTarget[1], target2 = global._renderTarget[2], target3 = global._renderTarget[3] ) {
	
	shader_set( shader );	
	if ( target0 != -1 ) surface_set_target_ext( 0, target0 );
	if ( target1 != -1 ) surface_set_target_ext( 1, target1 );
	if ( target2 != -1 ) surface_set_target_ext( 2, target2 );
	if ( target3 != -1 ) surface_set_target_ext( 3, target3 );
}

/// @function shader_reset_ext()
function shader_reset_ext() {
	
	shader_reset();	
	surface_reset_target();
	
}

/// @function shader_set_i(uniform name, value);
/// @param uniform name
/// @param  value
function shader_set_i( uni, value ) {
	var shd = shader_current();

	if ( shd == -1 ) return;
	
	// Save uniform id in the shader map
	if ( is_undefined( global._shaderMap[shd][? uni ] )) {
		global._shaderMap[shd][? uni ] = shader_get_uniform( shd, uni );
	}
	uni = global._shaderMap[shd][? uni ];

	shader_set_uniform_i( uni, value );

}

/// @function shader_set_f(uniform name, value);
/// @param uniform name
/// @param  value
function shader_set_f( uni, value ) {
	var shd = shader_current();

	if ( shd == -1 ) return;
	
	// Save uniform id in the shader map
	if ( is_undefined( global._shaderMap[shd][? uni ] )) {
		global._shaderMap[shd][? uni ] = shader_get_uniform( shd, uni );
	}
	uni = global._shaderMap[shd][? uni ];

	shader_set_uniform_f( uni, value );
}


/// @function shader_set_f_array(uniform name, value);
/// @param uniform name
/// @param  value
function shader_set_f_array( uni, value ) {
	var shd = shader_current();

	if ( shd == -1 ) return;
	
	// Save uniform id in the shader map
	if ( is_undefined( global._shaderMap[shd][? uni ] )) {
		global._shaderMap[shd][? uni ] = shader_get_uniform( shd, uni );
	}
	uni = global._shaderMap[shd][? uni ];

	shader_set_uniform_f_array( uni, value );
}

/// @function shader_set_f_buffer(uniform name, value);
/// @param	uniform name
/// @param  value
function shader_set_f_buffer( uni, buffer, offset = 0, count = 1 ) {
	var shd = shader_current();

	if ( shd == -1 ) return;
	
	// Save uniform id in the shader map
	if ( is_undefined( global._shaderMap[shd][? uni ] )) {
		global._shaderMap[shd][? uni ] = shader_get_uniform( shd, uni );
	}
	uni = global._shaderMap[shd][? uni ];

	shader_set_uniform_f_buffer( uni, buffer, offset, count );
}

/// @function shader_set_vec2(uniform name, value0, value1);
/// @param	uniform name
/// @param  value_or_vector
/// @param  value
function shader_set_vec2( uni, value0 = 0, value1 = undefined ) {
	
	var shd = shader_current();
	if ( shd == -1 ) return;
	
	// Save uniform id in the shader map
	if ( is_undefined( global._shaderMap[shd][? uni ] )) {
		global._shaderMap[shd][? uni ] = shader_get_uniform( shd, uni );
	}
	uni = global._shaderMap[shd][? uni ];
	
	var arr = [];
	if ( is_struct( value0 )) {
		arr[0] = value0.x;
		arr[1] = value0.y;
	}
	else {
		arr[0] = value0;
		arr[1] = value1 ?? value0;
	}
	shader_set_uniform_f_array( uni, arr );
}

/// @function shader_set_vec3(uniform name, value0, value1);
/// @param	{String}				uniform name
/// @param  {Real|Struct.Vector3}	value_or_vector
/// @param  {Real}					value
/// @param  {Real}					value
function shader_set_vec3( uni, value0 = 0, value1 = 0, value2 = 0 ) {
	
	var shd = shader_current();
	if ( shd == -1 ) return;
	
	// Save uniform id in the shader map
	if ( is_undefined( global._shaderMap[shd][? uni ] )) {
		global._shaderMap[shd][? uni ] = shader_get_uniform( shd, uni );
	}
	uni = global._shaderMap[shd][? uni ];
	
	var arr = [];
	if ( is_struct( value0 )) {
		arr[0] = value0.x;
		arr[1] = value0.y;
		arr[2] = value0.z;
	}
	else {
		arr[0] = value0;
		arr[1] = value1;
		arr[2] = value2;
	}
	shader_set_uniform_f_array( uni, arr );
}

/// @function shader_set_vec4( uniform name, value0, value1);
/// @param	uniform name
/// @param  value_or_vector
/// @param  value
/// @param  value
/// @param  value
function shader_set_vec4( uni, value0 = 0, value1 = 0, value2 = 0, value3 = 0 ) {
	
	var shd = shader_current();
	if ( shd == -1 ) return;
	
	// Save uniform id in the shader map
	if ( is_undefined( global._shaderMap[shd][? uni ] )) {
		global._shaderMap[shd][? uni ] = shader_get_uniform( shd, uni );
	}
	uni = global._shaderMap[shd][? uni ];
	
	var arr = [];
	
	arr[0] = value0;
	arr[1] = value1;
	arr[2] = value2;
	arr[3] = value3;
	
	shader_set_uniform_f_array( uni, arr );
}

/// @description shader_set_texture(uniform name, texture, filter );
/// @param uniform name
/// @param texture
/// @param filter
function shader_set_texture( uni, tex, filter = false ) {
	var shd = shader_current();
	
	if ( shd == -1 ) return;

	// Save uniform id in the shader map
	if ( is_undefined( global._shaderMap[shd][? uni ] )) {
		global._shaderMap[shd][? uni ] = shader_get_sampler_index( shd, uni );
	}
	uni = global._shaderMap[shd][? uni ];

	texture_set_stage( uni, tex ); 
	if ( filter ) gpu_set_tex_filter_ext( uni, filter );

}

/// @function shader_set_matrix
/// @param	uniform name
/// @param  value
function shader_set_matrix( uni, value ) {
	
	var shd = shader_current();
	
	if ( shd == -1 ) return;
	
	// Save uniform id in the shader map
	if ( is_undefined( global._shaderMap[shd][? uni ] )) {
		global._shaderMap[shd][? uni ] = shader_get_uniform( shd, uni );
	}
	uni = global._shaderMap[shd][? uni ];

	shader_set_uniform_matrix_array( uni, value );

}

/// @function shader_set_buffer
/// @param	uniform name
/// @param  buffer
/// @param  offset
/// @param  count
function shader_set_buffer( uni, value, offset = 0, count = 0 ) {
	
	var shd = shader_current();
	
	if ( shd == -1 ) return;
	
	// Save uniform id in the shader map
	if ( is_undefined( global._shaderMap[shd][? uni ] )) {
		global._shaderMap[shd][? uni ] = shader_get_uniform( shd, uni );
	}
	uni = global._shaderMap[shd][? uni ];

	shader_set_uniform_f_buffer( uni, value, offset, count );

}


/// @function	shader_set_colour( uniform name, colour, alpha );
/// @param		{String}	uniform name
/// @param		{Colour}	colour
/// @param		{Real}		alpha
function shader_set_colour( uni, col, alpha = 1.0 ) {
	var shd = shader_current();

	if ( shd == -1 ) return;

	var red     = colour_get_red( col ) / 255;
	var green   = colour_get_green( col ) / 255;
	var blue    = colour_get_blue( col ) / 255;

	var _col;
	_col[0] = red;
	_col[1] = green;
	_col[2] = blue;
	_col[3] = alpha;
	
	// Save uniform id in the shader map
	if ( is_undefined( global._shaderMap[shd][? uni ] )) {
		global._shaderMap[shd][? uni ] = shader_get_uniform( shd, uni );
	}
	uni = global._shaderMap[shd][? uni ];


	shader_set_uniform_f_array( uni, _col );

}

