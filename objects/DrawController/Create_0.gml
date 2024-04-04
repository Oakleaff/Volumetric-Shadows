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
fogBufferScaleCheck	= fogBufferScale;

// Toggle debug drawing
drawFog			= true;
enableShadows		= true;

drawDebug		= true;
drawDepthBuffer = false;
drawShadowMaps	= false;

sampleNoise		= 1.0;
useBlueNoise	= 1.0;
shadowPower		= 2.0;
shadowTreshold	= 0.2;
fogValueOutput	= 0.0;


drawBlend	= true;
drawBlur	= true;
blurRadius	= 5.0;

// Debug view
dbg_view( "Parameters", true, window_get_width() - 300, 10, 300, 320 );

dbg_checkbox( ref_create( self, "drawFog" ), "Fog on" );
dbg_checkbox( ref_create( self, "enableShadows" ), "Shadows on" );

dbg_slider( ref_create( self, "shadowPower" ), 1.0, 10.0, "Shadow power" );
dbg_slider( ref_create( self, "shadowTreshold" ), 0.0, 1.0, "Shadow treshold" );

dbg_slider_int( ref_create( self, "fogBufferScale" ), 1, 16, "Fog buffer scale" );

dbg_checkbox( ref_create( self, "drawBlur" ), "Blur" );
dbg_slider_int( ref_create( self, "blurRadius" ), 1.0, 20.0, "Blur radius" );

dbg_checkbox( ref_create( self, "drawBlend" ), "Additive blend" );

dbg_checkbox( ref_create( self, "useBlueNoise" ),	"Use blue noise" );
dbg_checkbox( ref_create( self, "sampleNoise" ),	"Use noise for fog volume" );

dbg_checkbox( ref_create( self, "fogValueOutput" ),	"Output fog value" );

dbg_color( ref_create( Level, "fogColour" ), "Fog Colour" );





// Rendering flags -- unused in this demo
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
		
		with ( oShape ) if  ( castShadows )	render();
		return;
	}
	
	/// @function do_instance_render();
	static do_instance_render = function() {
		
		with ( oShape )		render();
		
	}
	
	// Default material render
	update_shader_parameters( shdDefaultLit );
	shader_set_ext( shdDefaultLit );
	shader_set_f_array( "uTexCoord", Level.texture_uv );
	shader_set_f( "uEnableShadows", enableShadows ? 1.0 : 0.0 );
	
	camera_apply( Camera.camera );
	
		do_instance_render();
		
	matrix_reset();
	shader_reset_ext();
	
}


