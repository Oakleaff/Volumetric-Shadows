include( "CameraFunctions" );
require( "Vectors" );
require( "Quaternions" );
require( "MatrixFunctions" );

enum CAM_MODE { None, Orbit, Free, Locked, Animation };

/// @function	camera_init( fov, aspect, near, far )
/// @desc		Call in oCamera's step event
function camera_init( _fov = 70, _aspect = 16/9, _near = 1, _far = 10000 ) {

	camera	= camera_create();
	
	#region Settings

		active	= true;
		fov		= _fov;
		aspect	= _aspect;
		near	= _near;
		far		= _far;
		mode	= CAM_MODE.Free;
		
		moveSpeed = 300;
	
		renderShadows		= true;
		renderParticles		= true;
		
	#endregion
		
	#region Setup
	
		position		= new Vector3( 0.0 );
		lookAtPosition	= new Vector3( 1.0, 0.0, 0.0 );
		
		rotation = new Quaternion();

		forward = new Vector3( 1, 0, 0 );
		right	= new Vector3( 0, 1, 0 );
		up		= new Vector3( 0, 0, 1 );

		// Target for looking at
		// These control where the camera is looking TO
		lookAtTarget = {};
		lookAtTarget.instance = noone;
		lookAtTarget.position = lookAtPosition.Clone();
		lookAtTarget.rotation = rotation.Clone();
		
		// Target to move to
		// These control where the camera is looking FROM
		moveTarget = {};
		moveTarget.position			= position.Clone();
		moveTarget.rotation			= rotation.Clone();
		moveTarget.targetRotation	= rotation.Clone();
		moveTarget.length			= METER * 10;
		moveTarget.targetLength		= METER * 10;
		
		// Matrices
		viewMatrix	= matrix_build_lookat(	position.x,			position.y,			position.z, 
											lookAtPosition.x,	lookAtPosition.y,	lookAtPosition.z,
											up.x,				up.y,				up.z );
										
		projMatrix	= matrix_build_projection_perspective_fov( -fov, -aspect, near, far );

		viewMatrixInverse	= matrix_invert( viewMatrix );
		projMatrixInverse	= matrix_invert( projMatrix );
		VP_mat				= matrix_invert( viewMatrix );
		VP_mat_inverse		= matrix_invert( viewMatrix );

		camera_set_view_mat( camera, viewMatrix );
		camera_set_proj_mat( camera, projMatrix );
		
		frustumPoints = [];
		for ( var i = 0; i < 8; i ++ ) frustumPoints[i] = new Vector3();
	
	#endregion
	
	#region Shadow maps
	
		lightDirection				= new Vector3( 1, 1, -1 ).Normalized();

		shadowCascades				= 3;	// Number of shadow cascades
		shadowMapUpdateCounter		= 0;	// Update tick
		shadowMapUpdateInterval		= 1;	// Update interval for shadows (frames)

		shadowMap[0] = new ShadowMap();
		shadowMap[1] = new ShadowMap();
		shadowMap[2] = new ShadowMap();

		shadowMap[0].near =	self.near;			shadowMap[0].far = self.far * 0.05;
		shadowMap[1].near = shadowMap[0].far;	shadowMap[1].far = self.far * 0.25;
		shadowMap[2].near = shadowMap[1].far;	shadowMap[2].far = self.far * 0.5;

		shadowMap[0].boundaryFactor = 10.0;
		shadowMap[1].boundaryFactor = 10.0;
		shadowMap[2].boundaryFactor = 5.0;

	#endregion
	
	// Variables
	faceDirection	= 0;		// Facing direction on XY plane
	horAngle		= 0;		// Facing direction on XY plane
	verAngle		= 0;		// Vertical angle
	
	shake			= 0;
	
	mousePosition = new Vector3();
	
	/// @function set_default_position()
	function set_default_position() {
	
		moveTarget.rotation		= quaternion_create_euler( 0, 0, 0 );
		moveTarget.length		= METER * 20;
		moveTarget.targetLength	= METER * 20;
		
	}
	
	/// @function set_target_position( pos )
	function set_target_position( pos ) {

		moveTarget.position.Set( pos );
	
	}

}

/// @function	camera_update() 
/// @desc		Call in oCamera's step event
function camera_update() {
	
	static world_up = new Vector3( 0, 0, 1 );
	
	if ( lookAtTarget.instance != noone ) {
		if ( !instance_exists( lookAtTarget.instance )) {
			lookAtTarget.instance = noone;
		}
	}

	// Do camera position + lookAt update
	switch ( mode ) {
	
		case CAM_MODE.Orbit:
			cam_mode_orbit();
		break;
	
		case CAM_MODE.Free:
			cam_mode_free();
		break;
	
		case CAM_MODE.Animation:
			cam_mode_animation();
		break;
	
		default:
			cam_mode_default();
		break;
	}
	

	// Cam shake
	if ( shake > 0 ) {
	
		var _shake_dir = game_time * 0.1;
		var _shake_x = lengthdir_x( shake * random_range( 1, 2 ), _shake_dir );
		var _shake_y = lengthdir_y( shake * random_range( 1, 2 ), _shake_dir );
	
		var _shake_vec = new Vector3();
		_shake_vec.Add( vector_multiply( right,	_shake_x ));
		_shake_vec.Add( vector_multiply( up,		_shake_y ));
	
		position.x += _shake_vec.x;
		position.y += _shake_vec.y;
		position.z += _shake_vec.z;
	
		lookAtPosition.x -= _shake_vec.x;
		lookAtPosition.y -= _shake_vec.y;
		lookAtPosition.z -= _shake_vec.z;
	}
	shake = lerp( shake, 0, 0.1 );

	// Update vectors
	forward			= vector_to_point( position, lookAtPosition );
	right			= vector_cross( world_up, forward ).Normalized();
	up				= vector_cross( forward, right ).Normalized();
	
	faceDirection	= point_direction( 0, 0, forward.x, forward.y );

	// Update values
	viewMatrix	= matrix_build_lookat(	position.x,			position.y,			position.z, 
										lookAtPosition.x,	lookAtPosition.y,	lookAtPosition.z,
										up.x,				up.y,				up.z );
		
	camera_set_view_mat( camera, viewMatrix );

	var vm				= camera_get_view_mat( camera );
	var pm				= camera_get_proj_mat( camera );
	viewMatrixInverse	= matrix_invert( vm, true );
	projMatrixInverse	= matrix_invert( pm, true );
	VP_mat				= matrix_multiply( vm, pm );
	VP_mat_inverse		= matrix_invert( VP_mat, true );


	horAngle = faceDirection;
	verAngle = darcsin( forward.z );

	// Do shadow update
	if ( renderShadows ) camera_update_shadows();
	
}

#region Camera modes

	/// @function cam_mode_default()
	function cam_mode_default() {
		
		lookAtPosition.Zero();
		
		position.x = lengthdir_x( 100, current_time * 0.005 );
		position.y = lengthdir_y( 100, current_time * 0.005 );
		position.z = 50;
		
	}
	
	/// @function cam_mode_orbit()
	function cam_mode_orbit() {
		
		var xmove, ymove, zmove;
		xmove = 0;
		ymove = 0;
		zmove = 0;
		
		// Rotation
		if ( !is_mouse_over_debug_overlay() ) {
			if ( input_check_pressed( "camera_rotate" )) {
				mousePosition.x = window_mouse_get_x();
				mousePosition.y = window_mouse_get_y();
			}
		
			if ( input_check( "camera_rotate" )) {
				xmove = window_mouse_get_x() - mousePosition.x;
				ymove = window_mouse_get_y() - mousePosition.y;
		
				mousePosition.x = window_mouse_get_x();
				mousePosition.y = window_mouse_get_y();
			}
			else {
				mousePosition.x = window_mouse_get_x();
				mousePosition.y = window_mouse_get_y();
			
				xmove = -5.0 * ( input_check( "aim_left" ) -	input_check( "aim_right" ));
				ymove = -3.0 * ( input_check( "aim_up" ) -		input_check( "aim_down" ));
			}
		}
		
		moveTarget.targetRotation.Rotate_y( -ymove * 0.3, true );
		moveTarget.targetRotation.Rotate_z( xmove * 0.3, false );
	
		moveTarget.rotation.Slerp( moveTarget.targetRotation, 0.2 );
		
		// Movement
		xmove = input_check( "right" ) -		input_check( "left" );
		ymove = input_check( "down" ) -			input_check( "up" );
		zmove = input_check( "shoulder_r" ) -	input_check( "shoulder_l" );
	
		var targ = lookAtTarget.position;

		if ( xmove != 0 || ymove != 0 ) {
			var dir = point_direction( 0, 0, xmove, ymove ) - 90 + faceDirection;
			targ.x += lengthdir_x( moveSpeed, dir ) * DELTA;
			targ.y += lengthdir_y( moveSpeed, dir ) * DELTA;
		}
		if ( zmove != 0 ) {
			targ.z += zmove * moveSpeed * DELTA;
		}
		
		lookAtPosition.Lerp( lookAtTarget.position, 0.2 );
	
		position.Set( lookAtPosition );

		var pos = matrix_vector( moveTarget.rotation.Matrix(), moveTarget.length, 0, 0 );
		position.Add( pos );
		
		// Zoom
		var _check = true;
		if ( keyboard_check( vk_control )) _check = false;
	
		if ( _check ) {
			if ( mouse_wheel_down() )	moveTarget.targetLength *= 1.2;
			if ( mouse_wheel_up() )		moveTarget.targetLength /= 1.2;
		}
		
		moveTarget.length = lerp( moveTarget.length, moveTarget.targetLength, 0.2 );
		
		

	}
	
	/// @function cam_mode_free()
	function cam_mode_free() {

		
		var xmove, ymove, zmove;
		
		// Rotation
		
		xmove = window_mouse_get_x() - window_get_width() * 0.5;
		ymove = window_mouse_get_y() - window_get_height() * 0.5;
		
		window_mouse_set( window_get_width() * 0.5, window_get_height() * 0.5 );
		
		if ( xmove == 0 && ymove == 0 ) {
			xmove = -5.0 * ( input_value( "aim_left" ) -	input_value( "aim_right" ));
			ymove = -3.0 * ( input_value( "aim_up" ) -		input_value( "aim_down" ));
		}
		
		lookAtTarget.rotation.Rotate_y( -ymove * 0.3, true );
		lookAtTarget.rotation.Rotate_z( xmove * 0.3, false );
	
		// Movement
		xmove = input_value( "right" ) -		input_value( "left" );
		ymove = input_value( "down" ) -			input_value( "up" );
		zmove = input_value( "shoulder_r" ) -	input_value( "shoulder_l" );
	
		position.Add( vector_multiply( right,	moveSpeed * DELTA * xmove ));
		position.Add( vector_multiply( forward,	moveSpeed * DELTA * ymove ));
		position.Add( vector_multiply( up,		moveSpeed * DELTA * zmove ));
		
		
	}
	
	/// @function cam_mode_animation()
	function cam_mode_animation() {
		
		
	}

#endregion

#region Shadow maps

	/// @function ShadowMap()
	function ShadowMap() constructor {
	
		size			= 2048;
		near			= 1;		
		far				= 10;	
	
		camera			= camera_create(); 
		surface			= -1; 
		lookAt			= new Vector3();
		lookFrom		= new Vector3();
		width			= 0; 
		height			= 0; 
		viewMatrix		= matrix_build_identity();
		projMatrix		= matrix_build_identity();
		VP_matrix		= matrix_build_identity();
		VP_matrix_inv	= matrix_build_identity();
		frustumPoints	= -1;
		planeNear		= 0;
		planeFar		= 0;
		colour			= c_white;
		
		frustumPoints = [];
		for ( var i = 0; i < 8; i ++ ) frustumPoints[i] = new Vector3();
		
		frustumBounds = {};
		frustumBounds.x1 = 0;
		frustumBounds.x2 = 0;
		frustumBounds.y1 = 0;
		frustumBounds.y2 = 0;
		frustumBounds.z1 = 0;
		frustumBounds.z2 = 0;
		
	}

	/// @function	camera_update_shadows()
	/// @desc		Call in oCamera's step event
	function camera_update_shadows() {
		
		if ( !active )							exit;
		if ( !SETTINGS.graphics.enableShadows ) exit;

		// Shadow map update tick
		shadowMapUpdateCounter -= 1;
		if ( shadowMapUpdateCounter > 0 ) return;
		
		
		shadowMapUpdateCounter = shadowMapUpdateInterval;
	
		// Update camera frustum points
		calculate_frustum_points( self, near, far );
		var frustum_len = far - near;

		var c, i, i_mod;
		for ( c = 0; c < shadowCascades; c ++ ) {
	
			var map		= shadowMap[c];
			var points	= map.frustumPoints;
			var point;
		
			map.lookAt.Set( 0, 0, 0 );
		
			var near_val	= ( map.near - self.near ) / frustum_len;
			var far_val		= ( map.far - self.near ) / frustum_len;
			var val;
			for ( i = 0; i < 8; i ++ ) {
		
				i_mod = i mod 4;
				point = points[i];
	
				val = i < 4 ? near_val : far_val;
				point.x = lerp( frustumPoints[ i_mod ].x, frustumPoints[ i_mod + 4 ].x, val );
				point.y = lerp( frustumPoints[ i_mod ].y, frustumPoints[ i_mod + 4 ].y, val );
				point.z = lerp( frustumPoints[ i_mod ].z, frustumPoints[ i_mod + 4 ].z, val );
			
				map.lookAt.Add( point );
			}
		
			// Get the center point of the camera frustum - this is the light's lookat position
			map.lookAt.Multiply( 1 / 8 );
	
			map.lookFrom.Set( map.lookAt );
			map.lookFrom.Add( vector_multiply( lightDirection, -1.0 ));
			//map.rotation	= quaternion_to_point( map.lookFrom, map.lookAt, Level.up );
			map.viewMatrix	= matrix_build_lookat_vectors(	map.lookFrom, map.lookAt, Level.up );
		
	
			// Find the min..max boundaries of the shadow camera frustum
			var min_x = undefined;
			var max_x = undefined;
			var min_y = undefined;
			var max_y = undefined;
			var min_z = undefined;
			var max_z = undefined;
	
			var point;
			for ( i = 0; i < 8; i ++ ) {
				point = matrix_transform_vertex( map.viewMatrix, points[i].x, points[i].y, points[i].z );
	
				min_x = is_undefined( min_x ) ? point[0] : min( min_x, point[0] );
				max_x = is_undefined( max_x ) ? point[0] : max( max_x, point[0] );
				min_y = is_undefined( min_y ) ? point[1] : min( min_y, point[1] );
				max_y = is_undefined( max_y ) ? point[1] : max( max_y, point[1] );
				min_z = is_undefined( min_z ) ? point[2] : min( min_z, point[2] );
				max_z = is_undefined( max_z ) ? point[2] : max( max_z, point[2] );
			
			}
		

			var w = max_x - min_x;
			var h = max_y - min_y;
			if ( map.width != w || map.height != h ) {
				map.width		= w;
				map.height		= h;
		
				if ( min_z < 0 )	min_z *= map.boundaryFactor;
				else				min_z /= map.boundaryFactor;
				if ( max_z < 0 )	max_z /= map.boundaryFactor;
				else				max_z *= map.boundaryFactor;
			
				//// Increase max render distance to avoid gaps in shadow maps at angles
				//max_x	*= lerp( map.boundaryFactor, 1.0, 0.2 );
			
				map.projMatrix	= matrix_build_projection_ortho( w, -h, min_z, max_z );
		
				map.planeNear	= min_z;
				map.planeFar	= max_z;
			}

			camera_set_view_mat( map.camera, map.viewMatrix );
			camera_set_proj_mat( map.camera, map.projMatrix );

			map.VP_matrix = matrix_multiply(	map.viewMatrix, 
												map.projMatrix);
	
		}
	}

	/// @function	camera_update_shadow_surfaces()
	/// @desc		Call in oCamera's pre-draw event
	function camera_update_shadow_surfaces() {
		
		if ( !active )							exit;
		if ( !SETTINGS.graphics.enableShadows ) exit;

		var c;
		for ( c = 0; c < shadowCascades; c ++ ) {
	
			var map		= shadowMap[c];
	
			if ( !surface_exists( map.surface )) {
				map.surface = surface_create( map.size, map.size );
	
				surface_set_target( map.surface );
					draw_clear_alpha( c_black, 1 );
				surface_reset_target();
			}
		}
	
		
	}

	
#endregion
	
#region Frustum functions

	/// @function	calculate_frustum_points() {
	/// @param		camera		{Instance}
	/// @param		near		{Float}		Near plane distance
	/// @param		far			{Float}		Far plane distance
	/// @desc		returns an array containing the frustum corners in world-space
	function calculate_frustum_points( camera, near, far ) {
	
		static arr		= [];
		static result	= [];
	
		var t_fov = dtan( camera.fov * 0.5 );
	
		var x1 = near;
		var x2 = far;
		var y1 = x1 * t_fov * camera.aspect;
		var y2 = x2 * t_fov * camera.aspect;
		var z1 = x1 * t_fov;
		var z2 = x2 * t_fov;
	
		arr		= [];
		result	= [];
	
		// Near plane points
		array_push( arr, [ x1, -y1, -z1 ] );
		array_push( arr, [ x1, +y1, -z1 ] );
		array_push( arr, [ x1, +y1, +z1 ] );
		array_push( arr, [ x1, -y1, +z1 ] );
	
		// Far plane points
		array_push( arr, [ x2, -y2, -z2 ] );
		array_push( arr, [ x2, +y2, -z2 ] );
		array_push( arr, [ x2, +y2, +z2 ] );
		array_push( arr, [ x2, -y2, +z2 ] );
	
		var p, i, xx, yy, zz, vec;
	
		for ( i = 0; i < 8; i ++ ) {
		
			p = arr[i];
		
			// Origin
			xx = camera.position.x;
			yy = camera.position.y;
			zz = camera.position.z;
		
			// Forward
			xx += camera.forward.x * p[0];
			yy += camera.forward.y * p[0];
			zz += camera.forward.z * p[0];
		
			// Right
			xx += camera.right.x * p[1];
			yy += camera.right.y * p[1];
			zz += camera.right.z * p[1];
		
			// Up
			xx += camera.up.x * p[2];
			yy += camera.up.y * p[2];
			zz += camera.up.z * p[2];
		
			camera.frustumPoints[i].Set( xx, yy, zz );
		}
	
		//return result;
	
	}


	/// @function update_frustum_mesh()
	function update_frustum_mesh( ) {
	
		if ( frustumMesh != -1 ) vertex_delete_buffer( frustumMesh );
		frustumMesh = vertex_create_buffer();
	
		static pairs = [	[0, 1], [1, 2], [2, 3], [3, 0],
							[4, 5], [5, 6], [6, 7], [7, 4],
							[0, 4], [1, 5], [2, 6], [3, 7] ];
		static num_pairs = 12;
		static colours = [ c_lime, c_yellow, c_red ];
	
	
		vertex_begin( frustumMesh, VERTEXFORMAT );
	
		var c, p, map, pair, p0, p1, c0, c1;
		for ( c = 0; c < shadowCascades; c ++ ) {
	
			map = shadowMap[c];
		
			c0 = colours[c];
		

			var x1, y1, x2, y2, z1, z2;
			x1 = map.frustumBounds.x1;
			x2 = map.frustumBounds.x2;
			y1 = map.frustumBounds.y1;
			y2 = map.frustumBounds.y2;
			z1 = 0;//map.frustumBounds.z1;
			z2 = 0;//map.frustumBounds.z2;
			vbuffer_add_line( frustumMesh, x1, y1, z1, x2, y1, z1, c0, 1, c0, 1 );
			vbuffer_add_line( frustumMesh, x2, y1, z1, x2, y2, z1, c0, 1, c0, 1 );
			vbuffer_add_line( frustumMesh, x2, y2, z1, x1, y2, z1, c0, 1, c0, 1 );
			vbuffer_add_line( frustumMesh, x1, y2, z1, x1, y1, z1, c0, 1, c0, 1 );
		}
	
		vertex_end_freeze( frustumMesh );
	
	
	}

#endregion

