/// @description Draw to screen

draw_surface_ext( defaultBuffer,	0, 0, 1, 1, 0, c_white, 1 );


#region Screen space fog
	
	if ( drawFog ) {

		// Render screen space fog
		gpu_set_colorwriteenable( 1, 1, 1, 1 );
		surface_set_target( fogBuffer );
			draw_clear_alpha( c_black, 0 );
	
			update_shader_parameters( shdScreenSpaceFog );
			shader_set( shdScreenSpaceFog );
			
				shader_set_f( "uFogStart",	0.0 );
				shader_set_f( "uFogEnd",	METER * 50.0 );
		
				
				shader_set_f( "uEnableShadows",		enableShadows	 );
				shader_set_f( "uShadowPower",		shadowPower	 );
				shader_set_f( "uShadowTreshold",	shadowTreshold );
			
				shader_set_f( "uUseBlueNoise",		useBlueNoise ? 1.0 : 0.0 );
				shader_set_f( "uSampleNoise",		sampleNoise ? 1.0 : 0.0 );
	
				// Fog colour is determined by the surface draw colour
				draw_surface_ext( depthBuffer, 0, 0, 1.0 / fogBufferScale, 1.0 / fogBufferScale, 0, Level.fogColour, 1 );
			shader_reset();
	
		surface_reset_target();

		gpu_set_tex_filter( true );

		// Blur fog surface
		if ( drawBlur ) {
			var _width		= surface_get_width( fogBuffer );
			var _height		= surface_get_width( fogBuffer );
			var _temp_surf	= surface_create( _width, _height );
		
			var _blur_radius = blurRadius;
			var _blur_dir = new Vector3( -1.0, -1.0, 0.0 ).Normalized();

			// Hor blur
			surface_set_target( _temp_surf );
				draw_clear_alpha( c_black, 0 );
			
				shader_set( shdLinearBlur );
					shader_set_f( "uBlurRadius",		_blur_radius );
					shader_set_vec2( "uBlurDirection",	_blur_dir.x, _blur_dir.y );
					shader_set_vec2( "uTexSize",		_width, _height );
				
					draw_surface_ext( fogBuffer, 0, 0, 1, 1, 0, c_white, 1 );
				
				shader_reset();
			surface_reset_target();
		
			// Ver blur
			surface_set_target( fogBuffer );
				draw_clear_alpha( c_black, 0 );
	
				shader_set( shdLinearBlur );
				
					shader_set_f( "uBlurRadius",		_blur_radius / fogBufferScale );
					shader_set_vec2( "uBlurDirection", -_blur_dir.y, _blur_dir.x );
				
					draw_surface_ext( _temp_surf, 0, 0, 1, 1, 0, c_white, 1 );
				
				shader_reset();
			surface_reset_target();
	
			// Free temp surface
			surface_free( _temp_surf );
		}
		
		// Draw to screen
		gpu_set_colorwriteenable( 1, 1, 1, 0 );
	
		if ( drawBlend ) gpu_set_blendmode( bm_add );
		draw_surface_ext( fogBuffer, 0, 0, fogBufferScale, fogBufferScale, 0, c_white, 1 );
		gpu_reset_blendmode();
	

	
		gpu_set_tex_filter( false );
	}

#endregion

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

if ( drawDebug ) {
	var _str = "";
	_str += "Volumetric shadows demo 2024 by Oakleaff";
	_str += "\nWASD + QE to move";
	_str += "\nLMB to rotate view";
	_str += "\nMouse wheel to zoom";
	_str += "\nF1 toggle depth buffer";
	_str += "\nF2 toggle shadow maps";
	_str += "\nF12 toggle debug view";
	_str += "\nESC to quit";

	draw_set_colour( c_white );
	draw_text( 10, 20, _str );
}