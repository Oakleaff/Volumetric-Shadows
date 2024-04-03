/// @description Update surfaces & render shadows


var _width	= window_get_width();
var _height = window_get_height();

if ( fogBufferScaleCheck != fogBufferScale ) {
	fogBufferScaleCheck = fogBufferScale;
	
	surface_free( fogBuffer );
}

// Init rendering buffers and set them as render targets for shader_set_ext()
if ( !surface_exists( defaultBuffer ))		{
	defaultBuffer = surface_create( _width, _height );
	global._renderTarget[0] = defaultBuffer;
}
if ( !surface_exists( depthBuffer ))	{
	depthBuffer = surface_create( _width, _height );
	global._renderTarget[1] = depthBuffer;
}
if ( !surface_exists( fogBuffer ))	{
	fogBuffer = surface_create( _width / fogBufferScale, _height / fogBufferScale );
	
}

//if ( view_current > CameraController.cameraCount - 1 )	exit;

surface_set_target( defaultBuffer );
	draw_clear_alpha( c_black, 1 );
	camera_apply( Camera.camera );
surface_reset_target();

surface_set_target( depthBuffer );
	draw_clear_alpha( c_black, 1 );
	camera_apply( Camera.camera );
surface_reset_target();

var current_camera = CameraController.cameraList[ view_current ];
if ( !current_camera.active ) exit;

// Update shader parameters
if ( !global.updateShaderFlags.init ) {
	update_shader_parameters( shdSky,				current_camera );
	update_shader_parameters( shdDefaultLit,		current_camera );
	update_shader_parameters( shdScreenSpaceFog,	current_camera );
	update_shader_parameters( shdDefault,			current_camera );
	
	// Set flags as updated
	global.updateShaderFlags.init		= true;
	global.updateShaderFlags.lighting	= false;
	global.updateShaderFlags.fog		= false;
	global.updateShaderFlags.shadows	= false;
	global.updateShaderFlags.display	= false;
}

var camera_count = CameraController.cameraCount;
var C;
for ( C = 0; C < camera_count; C ++ ) {
	
	current_camera = CameraController.cameraList[C];
	
	if ( !current_camera.active ) continue;


	// Shadow maps
	if ( current_camera.renderShadows &&  SETTINGS.graphics.enableShadows ) {

		shader_set( shdShadowPass );
		render_flag_set( RENDER_FLAG.ShadowPass );
		
		for ( var c = 0; c < current_camera.shadowCascades; c ++ ) {
	
			var map		= current_camera.shadowMap[c];
			if ( surface_exists( map.surface )) {
				surface_set_target( map.surface ); 
	
				camera_apply( map.camera );
				draw_clear( c_black );
	
					shader_set_f( "uCamNear",	map.planeNear );
					shader_set_f( "uCamFar",	map.planeFar );

					// Draw instances
					render_instances( true );

				surface_reset_target();
			}
		}
	
		shader_reset();
		gpu_set_cullmode( cull_counterclockwise );
	}
}







