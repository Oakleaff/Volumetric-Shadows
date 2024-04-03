global.updateShaderFlags = {};
global.updateShaderFlags.init		= false;
global.updateShaderFlags.lighting	= true;
global.updateShaderFlags.fog		= true;
global.updateShaderFlags.shadows	= true;
global.updateShaderFlags.display	= true;

/// @function update_shader_parameters( shader, camera )
/// @param {Asset.GMShader}				shader
/// @param {Id.Instance<oCamera>}		camera	
function update_shader_parameters( shader = shdDefault, camera = Camera ) {
	
	var init = global.updateShaderFlags.init;

	static cam_position		= new Vector3();
	cam_position.Set( camera.position );
	
	// Update all flags
	if ( !global.updateShaderFlags.init ) {
		global.updateShaderFlags.lighting	= true;
		global.updateShaderFlags.fog		= true;
		global.updateShaderFlags.shadows	= true;
		global.updateShaderFlags.display	= true;
	}

	// Shadows
	if ( shader == shdDefaultLit || shader == shdScreenSpaceFog ) {
		
		if ( SETTINGS.graphics.enableShadows ) {
			
			var _shadow_array		= [];
			var _shadow_textures	= [];
			var _shadow_clip_values = [];
			var _shadow_map_sizes	= [];
			
			var c, m, i;
			_shadow_array = [];
			for ( c = 0; c < camera.shadowCascades; c ++ ) {
				for ( m = 0; m < 16; m ++ ) {
					array_push( _shadow_array, camera.shadowMap[c].VP_matrix[m] );
				}
			}
		
			var _clip_range = [];
			_clip_range[0] = camera.shadowMap[0].planeFar - camera.shadowMap[0].planeNear;
			_clip_range[1] = camera.shadowMap[1].planeFar - camera.shadowMap[1].planeNear;
			_clip_range[2] = camera.shadowMap[2].planeFar - camera.shadowMap[2].planeNear;
			_shadow_clip_values = [	camera.shadowMap[0].planeNear, camera.shadowMap[0].planeFar, _clip_range[0],
									camera.shadowMap[1].planeNear, camera.shadowMap[1].planeFar, _clip_range[1], 
									camera.shadowMap[2].planeNear, camera.shadowMap[2].planeFar, _clip_range[2] ];
								
			_shadow_map_sizes = [	camera.shadowMap[0].size, 
									camera.shadowMap[1].size, 
									camera.shadowMap[2].size ];
								
			_shadow_textures[0] = surface_get_texture( camera.shadowMap[0].surface );
			_shadow_textures[1] = surface_get_texture( camera.shadowMap[1].surface );
			_shadow_textures[2] = surface_get_texture( camera.shadowMap[2].surface );
			
		}
	}

	switch ( shader ) {

		case shdDefaultLit:
		shader_set( shdDefaultLit );
		
			// Camera
			shader_set_vec3(	"uCamPosition",		cam_position );
			shader_set_f(		"uCamNear",			camera.near );		
			shader_set_f(		"uCamFar",			camera.far );
			
			// Material
			if ( !global.updateShaderFlags.init ) {
				shader_set_f_array( "uTexCoord",		[ 0, 0, 1, 1 ] );
				shader_set_colour(	"uColour",			c_white );
			}
						
			// Lighting
			if ( global.updateShaderFlags.lighting ) {
				shader_set_f(		"uEnableLighting",	1.0 );
				shader_set_colour(	"uLightColour",		Level.lightColour );
				shader_set_colour(	"uAmbientColour",	Level.ambientColour );
				shader_set_vec3(	"uLightDirection",	Level.lightDirection );
			}

			if ( !global.updateShaderFlags.init ) {
				shader_set_colour(	"uSkyColour0",		Level.skyColour0	);
				shader_set_colour(	"uSkyColour1",		Level.skyColour1	);
			}
			
			// Shadows
			if ( SETTINGS.graphics.enableShadows ) {
				
				shader_set_f(		"uEnableShadows",		1.0 );
				shader_set_matrix(	"uDepthMatrix",			_shadow_array	);

				// Shadow textures
				shader_set_texture(	"uShadowMap0",			_shadow_textures[0], false );
				shader_set_texture(	"uShadowMap1",			_shadow_textures[1], false );
				shader_set_texture(	"uShadowMap2",			_shadow_textures[2], false );
				shader_set_f_array(	"uShadowMapSize",		_shadow_map_sizes );										
				shader_set_f_array(	"uShadowClipValues",	_shadow_clip_values );
				
			}
			

		shader_reset();
		break;
		
		
		case shdScreenSpaceFog:
		shader_set( shdScreenSpaceFog );
		
			// Defaults
			shader_set_f(		"uTime",			current_time );
			
			// Camera
			shader_set_vec3(	"uCamPosition",	Camera.position );
			shader_set_f(		"uCamNear",		Camera.near );
			shader_set_f(		"uCamFar",		Camera.far );
			
			// Material
			shader_set_f_array( "uTexCoord",		texture_get_uv_array( Level.noiseTexture ));
			shader_set_texture( "uNoiseTexture",	Level.noiseTexture );
		
			// The order is this way because the frustum corners have been declared in a different order in the camera's calculate_frustum_points()
			var frustum_points = [];
			var p0 = Camera.frustumPoints[7];
			var p1 = Camera.frustumPoints[6];
			var p2 = Camera.frustumPoints[4];
			var p3 = Camera.frustumPoints[5];
		
			array_push( frustum_points, p0.x, p0.y, p0.z );
			array_push( frustum_points, p1.x, p1.y, p1.z );
			array_push( frustum_points, p2.x, p2.y, p2.z );
			array_push( frustum_points, p3.x, p3.y, p3.z );
			shader_set_f_array( "uFrustumPoints", frustum_points );
		
			// Lighting
			if ( global.updateShaderFlags.lighting ) {
				shader_set_f(		"uEnableLighting",	1.0 );
				shader_set_colour(	"uLightColour",		Level.lightColour );
				shader_set_colour(	"uAmbientColour",	Level.ambientColour );
				shader_set_vec3(	"uLightDirection",	Level.lightDirection );
			}
			
			// Shadows
			if ( SETTINGS.graphics.enableShadows ) {
				
				shader_set_f(		"uEnableShadows",		1.0 );
				shader_set_matrix(	"uDepthMatrix",			_shadow_array	);

				// Shadow textures
				shader_set_texture(	"uShadowMap0",			_shadow_textures[0], false );
				shader_set_texture(	"uShadowMap1",			_shadow_textures[1], false );
				shader_set_texture(	"uShadowMap2",			_shadow_textures[2], false );
				shader_set_f_array(	"uShadowMapSize",		_shadow_map_sizes );										
				shader_set_f_array(	"uShadowClipValues",	_shadow_clip_values );
				
			}
			else shader_set_f(		"uEnableShadows",		0.0 );
			

		shader_reset();
		break;
	
		case shdSky:
		shader_set( shdSky );
	
			if ( !init ) {
				shader_set_colour(	"uColour0",			Level.skyColour0 );			// Lower half
				shader_set_colour(	"uColour1",			Level.skyColour1 );			// Upper half
			}
			
			if ( global.updateShaderFlags.lighting ) {
				shader_set_vec3( "uLightDirection", Level.lightDirection );
			}
		shader_reset();
		break;


		case shdDefault:
		shader_set( shdDefault );
			
			shader_set_f_array( "uTexCoord",		[ 0, 0, 1, 1 ] );
			shader_set_colour(	"uColour",			c_white, 1 );

		shader_reset();
		break;
	}

	
	

}