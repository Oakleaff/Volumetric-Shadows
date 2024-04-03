/// @description Render setup

// Setup 3d rendering
layer_force_draw_depth( true, 0 );
gpu_set_ztestenable( true );
gpu_set_alphatestenable( true );

view_enabled	= true;
view_visible[0] = true;

// Surfaces
defaultBuffer	= -1;
depthBuffer		= -1;


fogBuffer		= -1;
fogBufferScale	= 2.0;

// Toggle debug drawing
drawDebug		= true;
drawDepthBuffer = false;
drawShadowMaps	= false;

show_debug_overlay( drawDebug );

// Rendering flags -- unused in the demo
enum RENDER_FLAG {	
					None			= 0,
					Default			= 1, 
					Unlit			= 2, 
					DefaultLit		= 4, 
					ShadowPass		= 8, 
				};
global.__renderFlag = RENDER_FLAG.None;

/// @function render_flag_set( _flag )
function render_flag_set( _flag = RENDER_FLAG.None ) {
	global.__renderFlag = _flag;
}


//texture		= sprite_get_texture( texWhite, 0 );
//texture_uv	= texture_get_uv_array( texture );

/// @function render_instances( shadow_pass )
/// @param {Bool} shadow_pass
function render_instances( shadow_pass = false ) {
	
	if ( shadow_pass ) {
		
		with ( Level )	if  ( castShadows )	render();
		with ( oShape ) if  ( castShadows )	render();
		
		return;
	}
	
	/// @function do_instance_render();
	static do_instance_render = function() {
		
		with ( Level )		render();
		with ( oShape )		render();
		
	}
	
	// Default material render
	update_shader_parameters( shdDefaultLit );
	shader_set_ext( shdDefaultLit );
	shader_set_f_array( "uTexCoord", Level.texture_uv );
	
	

	camera_apply( Camera.camera );
	
		do_instance_render();
		
	matrix_reset();
	shader_reset_ext();
	
}


