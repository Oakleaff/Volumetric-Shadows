/// @description 


//if ( view_current > CameraController.cameraCount - 1 )	exit;

var current_camera = CameraController.cameraList[ view_current ];
if ( !current_camera.active ) exit;

camera_apply( current_camera.camera );
draw_clear_alpha( c_red, 1 );
gpu_set_colorwriteenable( 1, 1, 1, 0 );

// Update shader parameters
update_shader_parameters( shdScreenSpaceFog,	current_camera );

#region Render sky


	// Sphere
	update_shader_parameters( shdSky, current_camera );
	shader_set_ext( shdSky  );
	camera_apply( current_camera.camera );

	gpu_set_ztestenable( false );
	gpu_set_cullmode( cull_noculling );
	
		matrix_transform( current_camera.position.x, current_camera.position.y, current_camera.position.z, 0, 0, 0, 100, 100, 100 );
			vertex_submit( Assets.sphere[1].mesh, pr_trianglelist, Level.noiseTexture );
		matrix_reset();
	
	
	shader_reset_ext();
	
	gpu_set_cullmode( cull_counterclockwise );
	gpu_set_ztestenable( true );
	
#endregion

gpu_set_colorwriteenable( 1, 1, 1, 0 );

// Render instances
if ( SETTINGS.graphics.renderInstances ) render_instances();
	

