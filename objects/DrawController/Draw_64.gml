/// @description Draw to screen

draw_surface_ext( defaultBuffer,	0, 0, 1, 1, 0, c_white, 1 );


// Screen space fog
surface_set_target( fogBuffer );
	draw_clear_alpha( c_black, 0 );
	
	update_shader_parameters( shdScreenSpaceFog );
	
	gpu_set_colorwriteenable( 1, 1, 1, 1 );
	shader_set( shdScreenSpaceFog );
		shader_set_f( "uShadowPower",		1.0 );
		shader_set_f( "uShadowTreshold",	0.1 );
	
		// Fog colour is determined by the surface draw colour
		draw_surface_ext( depthBuffer, 0, 0, 1.0 / fogBufferScale, 1.0 / fogBufferScale, 0, Level.fogColour, 1 );
	shader_reset();
	
surface_reset_target();

gpu_set_colorwriteenable( 1, 1, 1, 0 );
gpu_set_tex_filter( true );
draw_surface_ext( fogBuffer,	0, 0, fogBufferScale, fogBufferScale, 0, c_white, 1 );
gpu_set_tex_filter( false );


// Debug draw
if ( drawDepthBuffer ) draw_surface_ext( depthBuffer,		0, 0, 0.5, 0.5, 0, c_white, 1 );

//Shadow maps
if ( drawShadowMaps ) {
	var _camera = CameraController.cameraList[0];
	var _scale, xx;
	_scale = 0.1;
	for ( var i = 0; i < _camera.shadowCascades; i ++ ) {

		xx = _camera.shadowMap[i].size * i * _scale;
		if ( surface_exists( _camera.shadowMap[i].surface )) {
			draw_surface_ext( _camera.shadowMap[i].surface, xx, 0, _scale, _scale, 0, c_white, 1 );
		}
	}
}


var _str = "";
_str += "Volumetric shadows demo 2024 by Oakleaff";
_str += "\nWASD + QE to move";
_str += "\nLMB to rotate view";
_str += "\nMouse wheel to zoom";
_str += "\nF1 toggle depth buffer";
_str += "\nF2 toggle shadow maps";
_str += "\nF12 toggle debug view";

draw_set_colour( c_white );
draw_text( 10, 10, _str );