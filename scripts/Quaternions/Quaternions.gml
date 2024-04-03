/// Quaternion function library by Oakleaff

include( "Quaternions" );

/// @function	Quaternion()
/// @param		{Real}					w			
/// @param		{Real|Struct.Vector3}	x_or_vector	
/// @param		{Real}					y			
/// @param		{Real}					z			
function Quaternion( _w = 1, _x = 0, _y = 0, _z = 0 ) constructor { 
	
	w = _w;
	
	if ( is_struct( _x )) { 
		x = _x.x;
		y = _x.y;
		z = _x.z;
	}
	else {
		x = _x;
		y = _y;
		z = _z;
	}
	
	length		= 1;
	sqrLength	= 1;
	
	/// @function Set
	/// @param w_or_quat
	/// @param x
	/// @param y
	/// @param z
	static Set = function( ww = 1, xx = 0, yy = 0, zz = 0 ) {
	
		if ( is_struct( ww )) {
			w = ww.w;
			x = ww.x;
			y = ww.y;
			z = ww.z;
		}
		else {
			w = ww;
			x = xx;
			y = yy;
			z = zz;
		}
		
		return self;
		
	}

	// Normalize the quaternion
	static Normalize = function() {
		
		var l = ( x * x + y * y + z * z + w * w );
		
		if ( l <= 0 ) {
			w = 1;
			x = 0;
			y = 0;
			z = 0;
		}
		else {
			sqrLength	= l;
			l = sqrt( l );
			w /= l;
			x /= l;
			y /= l;
			z /= l;
			
			length		= l;
			
		}
		
		return self;
	}
	
	// Return normalized quaternion
	static Normalized = function() {
		Normalize();
		
		return new Quaternion( w, x, y, z );
	}
	
	// Get magnitude
	static Magnitude = function() {
		var l = sqrt( x * x + y * y + z * z + w * w );
		return l;
	}
	
	// Get quaternion as a matrix
	static Matrix = function() {
		
		return quaternion_to_matrix( self );
		
	}
	
	/// @function Rotate_x( angle, local ) {
	/// @param angle
	/// @param local
	static Rotate_x = function( angle, local = false ) {
		
		var q;
		q		= quaternion_rotate_x( self, angle, local );
		
		w = q.w;
		x = q.x;
		y = q.y;
		z = q.z;
		delete q;		
	}
	
	/// @function Rotate_y( angle, local ) {
	/// @param angle
	/// @param local
	static Rotate_y = function( angle, local = false ) {
		
		var q;
		q		= quaternion_rotate_y( self, angle, local );
		
		w = q.w;
		x = q.x;
		y = q.y;
		z = q.z;
		delete q;		
	}
	
	/// @function Rotate_z( angle, local ) {
	/// @param angle
	/// @param local
	static Rotate_z = function( angle, local = false ) {
		
		var q;
		q		= quaternion_rotate_z( self, angle, local );
		
		w = q.w;
		x = q.x;
		y = q.y;
		z = q.z;
		delete q;	
	}
	
	/// @function RotateAxis( axis, angle )
	/// @param axis
	/// @param angle
	static RotateAxis = function( axis, angle ) {
		
		var q;
		q		= quaternion_rotate_axis( self, axis, angle );
		
		w = q.w;
		x = q.x;
		y = q.y;
		z = q.z;
		delete q;	
	}
	
	/// @function Slerp( quat, value, dt ) {
	/// @param quat
	/// @param value
	/// @param dt
	static Slerp = function( quat, value, dt = 1 ) {
		
		var q;
		q		= quaternion_slerp( self, quat, value, dt );
		
		w = q.w;
		x = q.x;
		y = q.y;
		z = q.z;
		delete q;
	}
	
	/// @function Multiply( quat, local )
	/// @param quat	{Quaternion}
	/// @param local {bool}
	static Multiply = function( quat, local = false ) {
		
		if ( local )	quaternion_multiply( self, quat, self );
		else			quaternion_multiply( quat, self, self );
		
	}
	
	/// @function Clone() {
	static Clone = function() {
		return new Quaternion( w, x, y, z );
	}
	
	// Get Array
	/// @function GetArray()
	static GetArray = function() {
		return [w, x, y, z];
	}
}

/// @function	quaternion_multiply( quat1, quat2 )
/// @param		quat1
/// @param		quat2
/// @param		target_quaternion
function quaternion_multiply( q1, q2, q_target = noone ) {
	
	gml_pragma( "forceinline" );
	
	//if ( q1.w == 0 || q2.w == 0 ) return quaternion_multiply_zero( q1, q2, q_target );

	// Multiplies two quaternions together, adding one rotation onto another.

	//var _w = -q1.x * q2.x - q1.y * q2.y - q1.z * q2.z + q1.w * q2.w;
	//var _x =  q1.x * q2.w + q1.y * q2.z - q1.z * q2.y + q1.w * q2.x;
    //var _y = -q1.x * q2.z + q1.y * q2.w + q1.z * q2.x + q1.w * q2.y;
    //var _z =  q1.x * q2.y - q1.y * q2.x + q1.z * q2.w + q1.w * q2.z;
	
	// Juju implementation
	var _w = q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
    var _x = q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y;
    var _y = q1.w * q2.y + q1.y * q2.w + q1.z * q2.x - q1.x * q2.z;
    var _z = q1.w * q2.z + q1.z * q2.w + q1.x * q2.y - q1.y * q2.x;

	if ( q_target == noone ) return new Quaternion( _w, _x, _y, _z );
	
	// Set target quaternion values
	q_target.w = _w;
	q_target.x = _x;
	q_target.y = _y;
	q_target.z = _z;
	
	return q_target;

}

/// @function	quaternion_multiply_zero( quat1, quat2 )
/// @param		quat1
/// @param		quat2
/// @param		target_quaternion
function quaternion_multiply_zero( q1, q2, q_target = noone ) {

	gml_pragma( "forceinline" );
	
	if ( q1.w == 0 ) {
		var _w = -q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
		var _x =  q1.x * q2.w + q1.y * q2.z - q1.z * q2.y;
	    var _y = -q1.x * q2.z + q1.y * q2.w + q1.z * q2.x;
	    var _z =  q1.x * q2.y - q1.y * q2.x + q1.z * q2.w;
	}
	else {
		var _w = -q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
		var _x =  q1.y * q2.z - q1.z * q2.y + q1.w * q2.x;
	    var _y = -q1.x * q2.z + q1.z * q2.x + q1.w * q2.y;
	    var _z =  q1.x * q2.y - q1.y * q2.x + q1.w * q2.z;
	}
   
	if ( q_target == noone ) return new Quaternion( _w, _x, _y, _z );
	
	// Set target quaternion values
	q_target.w = _w;
	q_target.x = _x;
	q_target.y = _y;
	q_target.z = _z;
	
	return q_target;

}

/// @function	quaternion_multiply_scalar( quat1, scalar  )
/// @param		quat1
/// @param		scalar
function quaternion_multiply_scalar( q, s ) {
	
	return new Quaternion( q.w * s, q.x * s, q.y * s, q.z * s );

}

/// @function	quaternion_add( quat1, scalar  )
/// @param		quat1
/// @param		quat2
function quaternion_add( q1, q2 ) {
	
	return new Quaternion( q1.w + q2.w, q1.x + q2.x, q1.y + q2.y, q1.z + q2.z );
	
}

// Returns Vector3[xrot, yrot, zrot] euler angles from quaternion in world space
/// @function quaternion_get_euler( quaternion)
/// @param quaternion
function quaternion_get_euler( quat ) {
	
	var _w = quat.w;
	var _x = quat.x;
	var _y = quat.y;
	var _z = quat.z;


	var a, rx, ry, rz;

	rx = -radtodeg( arctan2( 2 * ( _w * _x + _y * _z), 1 - 2 * ( _x * _x + _y * _y )));
							   	   	         	  				      	   	       
	rz = -radtodeg( arctan2( 2 * ( _w * _z + _x * _y), 1 - 2 * ( _y * _y + _z * _z )));
										    
	a=2*(_w*_y-_z*_x)

	if a>=1
	{
	    rx=-radtodeg(2*arctan2(_x,_w))
	    ry=-90
	    rz=0
		return new Vector3( rx, ry, rz );

	}

	if a<=-1
	{
	    rx=-radtodeg(2*arctan2(_x,_w))
	    ry=90
	    rz=0
		return new Vector3( rx, ry, rz );

	}

	ry=-radtodeg(arcsin(2*(_w*_y-_z*_x)))

	return [ rx, ry, rz ];

}

/// @description quaternion_get_conjugate( quaternion );
/// @arg quaternion
function quaternion_get_conjugate( quat ) {
	
	gml_pragma( "forceinline" );
	
	// Return the inverse of the input (unit) quaternion

	var _w = quat.w;
	var _x = -quat.x;
	var _y = -quat.y;
	var _z = -quat.z;

	return new Quaternion( _w, _x, _y, _z );
}

/// @description quaternion_conjugate( quaternion );
/// @arg quaternion
function quaternion_conjugate( quat ) {
	
	gml_pragma( "forceinline" );
	
	// Return the inverse of the input (unit) quaternion

	quat.w = quat.w;
	quat.x = -quat.x;
	quat.y = -quat.y;
	quat.z = -quat.z;

	return quat;
}

// https://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToMatrix/index.htm
/// @function quaternion_to_matrix( quaternion );
/// @param quaternion
function quaternion_to_matrix( q ) {
	
	gml_pragma( "forceinline" );
	
	// Converts the quaternion into a 4x4 rotation matrix
	var _w = q.w; 
	var _x = q.x; 
	var _y = q.y; 
	var _z = q.z; 
	
	var _w2 = _w * _w;
	var _x2 = _x * _x;
	var _y2 = _y * _y;
	var _z2 = _z * _z;
	
	var l = ( _w2 + _x2 + _y2 + _z2 );
	if ( l == 0 ) l = 1;
	
	var len;
	
	// Check if we can use precomputed length
	q.sqrLength	= l;
	len			= sqrt( l );
	q.length	= len;
	len = 1.0 / len;
	
	_w *= len;
	_x *= len;
	_y *= len;
	_z *= len;

	// Column-major			
	var matrix = [	1 - 2*_y2 - 2*_z2,		2*_x*_y + 2*_z*_w,		2*_x*_z - 2*_y*_w,		0,
					2*_x*_y - 2*_z*_w,		1 - 2*_x2 - 2*_z2,		2*_y*_z + 2*_x*_w,		0,
					2*_x*_z + 2*_y*_w,		2*_y*_z - 2*_x*_w,		1 - 2*_x2 - 2*_y2,		0,
					0,						0,						0,						1 ];

	return ( matrix );
	
	
	
	
}



/// @description transform_world_to_local( position, rotation, target );
/// @arg position	{Vec3}
/// @arg rotation	{Quaternion/matrix}
/// @arg target		{Vec3}
function transform_world_to_local( position, rotation, target ) {
	// Transform Vector3 "target" from world space to local space defined by Vector3 "position" and matrix/quaternion "rotation"

	// New vector
	var tempTarget = new Vector3();
	
	tempTarget.x = target.x;
	tempTarget.y = target.y;
	tempTarget.z = target.z;
	
	tempTarget.x -= position.x;
	tempTarget.y -= position.y;
	tempTarget.z -= position.z;


	var quat, matrix, newPos;
	if ( is_struct( rotation )) {
		quat	= quaternion_get_conjugate( rotation );
		matrix	= quaternion_to_matrix( quat );
		
	}
	else {
		matrix = matrix_invert( rotation );
	}

	var newPos = matrix_transform_vertex( matrix, tempTarget.x, tempTarget.y, tempTarget.z );
	
	return new Vector3( newPos[0], newPos[1], newPos[2] );

}

/// @description quaternion_create_euler( xrot, yrot, zrot );
/// @arg xrot
/// @arg yrot
/// @arg zrot
function quaternion_create_euler( xrot, yrot, zrot ) {
	// 

	/*
	    Arguments:
	        0 rotx Euler angles in degrees
	        1 roty
	        2 rotz
        
	    Returns:
	        creates a quaternion using Euler angles
	*/

	var cx, cy, cz, sx, sy, sz;

	xrot = -degtorad( xrot ) / 2;
	yrot = -degtorad( yrot ) / 2;
	zrot = -degtorad( zrot ) / 2;

	cx = cos( xrot ); // Roll
	cy = cos( yrot ); // Pitch
	cz = cos( zrot ); // Yaw

	sx = sin( xrot );
	sy = sin( yrot );
	sz = sin( zrot );

	var cyz = cy * cz;
	var syz = sy * sz;

	var _w = cx * cyz + sx * syz;
	var _x = sx * cyz - cx * syz;
	var _y = cx * sy * cz + sx * cy * sy;
	var _z = cx * cy * sz - sx * sy * cz;

	return new Quaternion( _w, _x, _y, _z );

}


/// @function quaternion_create_vector( forward, up )
/// @param F
/// @param U
function quaternion_create_vector( F, U ) {

	// your code from before
	F = F.Normalized();		// lookAt
	U = U.Normalized();		// Up vector
	
	//var U = vector_cross( R, F );                  // rotatedup
	var R	= vector_cross( F, U ).Normalized();
	U		= vector_cross( F, R ).Normalized();
	
	// note that R needed to be re-normalized
	// since F and worldUp are not necessary perpendicular
	// so must remove the sin(angle) factor of the cross-product
	// same not true for U because dot(R, F) = 0

	// adapted source
	var q = new Quaternion();
	var trace = R.x + U.y + F.z;
	
	if ( trace > 0.0 ) {
		var s = 0.5 / sqrt(trace + 1.0);
		q.w = 0.25 / s;
		q.x = ( U.z - F.y ) * s;
		q.y = ( F.x - R.z ) * s;
		q.z = ( R.y - U.x ) * s;
	} 
	else {
		if ( R.x > U.y && R.x > F.z ) {
			var s = 2.0 * sqrt( 1.0 + R.x - U.y - F.z );
			q.w = ( U.z - F.y ) / s;
			q.x = 0.25 * s;
			q.y = ( U.x + R.y ) / s;
			q.z = ( F.x + R.z ) / s;
		  } 
	  else if ( U.y > F.z ) {
		var s = 2.0 * sqrt( 1.0 + U.y - R.x - F.z );
		q.w = ( F.x - R.z ) / s;
		q.x = ( U.x + R.y ) / s;
		q.y = 0.25 * s;
		q.z = ( F.y + U.z ) / s;
	  } 
	  else {
		    var s = 2.0 * sqrt( 1.0 + F.z - R.x - U.y );
		    q.w = ( R.y - U.x ) / s;
		    q.x = ( F.x + R.z ) / s;
		    q.y = ( F.y + U.z ) / s;
		    q.z = 0.25 * s;
		}
	}
	
	return q;
}

/// @description quaternion_rotate_x( quaternion, angle, local )
/// @param quat
/// @param angle
/// @param local
function quaternion_rotate_x( quat, angle, localSpace = false ) {
	
	gml_pragma( "forceinline" );

	var _new = new Quaternion( dcos( angle / 2 ), dsin( angle / 2 ), 0, 0  );

	if ( localSpace )	return quaternion_multiply( quat, _new );
	else				return quaternion_multiply( _new, quat );
	
	//if ( localSpace ) {
	//	return quaternion_multiply( quat, _new );
	//}

	//return quaternion_multiply( _new, quat );

}

/// @description quaternion_rotate_y( quaternion, angle, local )
/// @param quat
/// @param angle
/// @param local
function quaternion_rotate_y( quat, angle, localSpace = false ) {
	
	gml_pragma( "forceinline" );

	var _new = new Quaternion( dcos( angle / 2 ), 0, dsin( angle / 2 ), 0  );

	if ( localSpace )	return quaternion_multiply( quat, _new );
	else				return quaternion_multiply( _new, quat );

}

/// @description quaternion_rotate_z( quaternion, angle, local )
/// @param quat
/// @param angle
/// @param local
function quaternion_rotate_z( quat, angle, localSpace = false ) {
	
	gml_pragma( "forceinline" );

	var _new = new Quaternion( dcos( angle / 2 ), 0, 0, dsin( angle / 2 ) );

	if ( localSpace )	return quaternion_multiply( quat, _new );
	else				return quaternion_multiply( _new, quat );

}

/// @function quaternion_slerp( quat from, quat to, value, dt )
/// @param quat from
/// @param quat tp
/// @param value
/// @param dt
function quaternion_slerp( quat1, quat2, T, dt = 1 ) {
	
	gml_pragma( "forceinline" );

	
	// Framerate independent slerp
	if ( dt != 1 ) T = 1.0 - power( 1.0 - T, dt );

	// Slerp vs lerp treshold
	var delta = 0.001;

	var w1 = quat1.w;
	var x1 = quat1.x;
	var y1 = quat1.y;
	var z1 = quat1.z;

	var w2 = quat2.w;
	var x2 = quat2.x;
	var y2 = quat2.y;
	var z2 = quat2.z;

	var to = new Quaternion( 0, 0, 0, 0 );

	var omega, sinom, scale0, scale1;

	// Cos omega
	var cosom = x1 * x2 + y1 * y2 + z1 * z2 + w1 * w2;

	// Adjust signs ( if neccessary )
	if ( cosom < 0 ) { 
		cosom = -cosom; 
		to.x = -x2; 
		to.y = -y2;
		to.z = -z2;
		to.w = -w2;
	
	}
	else {
		to.w = w2;
		to.x = x2;
		to.y = y2;
		to.z = z2;
	
	}

	// Calculate coefficients
	if ( (1 - cosom ) > delta ) {
	
		omega	= arccos( cosom );
		sinom	= sin( omega );
		scale0	= sin(( 1.0 - T ) * omega ) / sinom;
		scale1	= sin( T * omega ) / sinom;
	
	}
	else {
		scale0	= 1 - T;
		scale1	= T;
	}

	var quat = new Quaternion();
	quat.w = scale0 * w1 + scale1 * to.w;
	quat.x = scale0 * x1 + scale1 * to.x;
	quat.y = scale0 * y1 + scale1 * to.y;
	quat.z = scale0 * z1 + scale1 * to.z;
	quat.Normalize();

	return quat;
	
}

/// @description quaternion_create_axis_angle( axis, angle );
/// @param axis
/// @param angle
function quaternion_create_axis_angle( vec, angle ) {

	gml_pragma( "forceinline" );

	//a = angle to rotate
	//[x, y, z] = axis to rotate around (unit vector)

	//R = [cos(a/2), sin(a/2)*x, sin(a/2)*y, sin(a/2)*z]
	
	angle /= 2.0;
	var sinAngle = dsin( angle );

	var _w = dcos( angle );
	var _x = vec.x * sinAngle;
	var _y = vec.y * sinAngle;
	var _z = vec.z * sinAngle;

	return new Quaternion( _w, _x, _y, _z );
}

/// @function			quaternion_rotate_axis( quat, axis, angle );
/// @arg quaternion		quaternion
/// @arg axis			Vector3
/// @arg angle			float
function quaternion_rotate_axis ( quat, axis, angle )  {


	var newQuat = quaternion_create_axis_angle( axis, angle );

	return ( quaternion_multiply( newQuat, quat ));


}

/// @description quaternion_angle( a, b );
/// @arg quaternion a
/// @arg quaternion b
function quaternion_angle( quat1, quat2 ) {
	
	if ( quaternion_equal( quat1, quat2 )) {
		return 0;
	}

	var w1 = quat1.w;
	var x1 = quat1.x;
	var y1 = quat1.y;
	var z1 = quat1.z;

	var w2 = quat2.w;
	var x2 = quat2.x;
	var y2 = quat2.y;
	var z2 = quat2.z;
	
	var dot = ( w1 * w2 + x1 * x2 + y1 * y2 + z1 * z2 );

	dot = clamp( dot, -1, 1 );
	var angle = darccos( dot ) * 2;/// ( mag1 * mag2 ));

	return angle;

}

/// @description matrix_to_quaternion( matrix );
/// @arg matrix
function matrix_to_quaternion( _matrix ) {
	// COnverts a 4x4 column-major rotation matrix into a quaternion

	// Convert GM's 1d matrix into a 2d array matrix
	var matrix = matrix_convert_2d( _matrix );

	var nxt		= [ 1, 2, 0 ];
	var quat	= new Quaternion();
	var m = matrix;
	var t;
	
	if ( m[2][2] < 0 )  { 
		if ( m[0][0] > m[1][1] ) { 
			t = 1 + m[0][0] - m[1][1] - m[2][2]; 
		
			quat.x = t;
			quat.y = m[0][1] + m[1][0];
			quat.z = m[2][0] + m[0][2];
			quat.w = m[1][2] - m[2][1];
		} 
		else { 
			t = 1 - m[0][0] + m[1][1] - m[2][2]; 
			
			quat.x = m[0][1] + m[1][0];
			quat.y = t;
			quat.z = m[1][2] + m[2][1];
			quat.w = m[2][0] - m[0][2];
		} 
	} 
	else { 
		if (m[0][0] < -m[1][1]) { 
			t = 1 - m[0][0] - m[1][1] + m[2][2]; 
			
			quat.x = m[2][0] + m[0][2];
			quat.y = m[1][2] + m[2][1];
			quat.z = t;
			quat.w = m[0][1] - m[1][0];
		} 
		else { 
			t = 1 + m[0][0] + m[1][1] + m[2][2]; 
			
			quat.x = m[1][2] - m[2][1];
			quat.y = m[2][0] - m[0][2];
			quat.z = m[0][1] - m[1][0];
			quat.w = t;
		} 
	} 
 
	t = 0.5 / sqrt( t );
	quat.x *= t;
	quat.y *= t;
	quat.z *= t;
	quat.w *= t;
	
	return quat;

}

/// @description quaternion_orient_up( quaternion, up vector, degrees)
/// @arg quaternion
/// @arg up vector
/// @arg degrees
function quaternion_orient_up( quat, up, angle ) {
	
	//Get quaternion up vector

	var matrix = quaternion_to_matrix( quat );
	var q_up = matrix_vector( matrix, 0, 0, 1 );

	//log( q_up );

	//Get dot product between quaternion up and provided up
	var dot = q_up.x * up.x + q_up.y * up.y + q_up.z * up.z;

	if (dot < 1 && dot >- 1)
	{
		//log( dot );
		var aDot = arccos(dot);
	    dot = min( aDot, degtorad( angle ));
    
	    var vec, _quat;
	    vec    = vector_cross(q_up, up);
	    vec.Normalize();

	    _quat   = quaternion_create_axis_angle( vec, radtodeg( dot ));
	    _quat   = quaternion_multiply( _quat, quat );
    
	
	    return (_quat);
    
	    exit;
	}

	else if (dot <= -1)
	{
	    var _quat   = quaternion_create_axis_angle( new Vector3( 1, 0, 0 ), angle );
	     _quat		= quaternion_multiply( _quat, quat );
    
	    return (_quat);
     
	    exit;
	}

	//Return same quaternion
	return ( quat );

}

/// @description quaternion_orient_towards( quaternion, up vector, degrees)
/// @arg quaternion
/// @arg target vector
/// @arg degrees
function quaternion_orient_towards( quat, target, angle ) {
	
	//Get quaternion up vector

	var matrix	= quaternion_to_matrix( quat );
	var q_up	= matrix_vector( matrix, 1, 0, 0 );

	//log( q_up );

	//Get dot product between quaternion up and provided up
	var dot = q_up.x * target.x + q_up.y * target.y + q_up.z * target.z;

	if (dot < 1 && dot >- 1)
	{
		//log( dot );
		var aDot = arccos(dot);
	    dot = min( aDot, degtorad( angle ));
    
	    var vec, _quat;
	    vec    = vector_cross( q_up, target );
	    vec.Normalize();

	    _quat   = quaternion_create_axis_angle( vec, radtodeg( dot ));
	    _quat   = quaternion_multiply( _quat, quat, _quat );
    
	
	    return (_quat);
    
	    exit;
	}

	else if (dot <= -1)
	{
	    var _quat   = quaternion_create_axis_angle( new Vector3( 0, 0, 1 ), angle );
	     _quat		= quaternion_multiply( _quat, quat, _quat );
    
	    return (_quat);
     
	    exit;
	}

	//Return same quaternion
	return ( quat );

}

//http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-17-quaternions/#how-do-i-create-a-quaternion-in-glsl-
/// @function quaternion_to_point( from, to );
/// @param from		{Vec3}
/// @param to		{Vec3}
/// @param up		{Vec3}
/// @param force_up	{Bool}
function quaternion_to_point( from, to, _up = new Vector3( 0, 0, 1 ), force = false ) {
	
	gml_pragma( "forceinline" );
	
	static v_forward = new Vector3( 1.0, 0.0, 0.0 );
	static v_up		 = new Vector3( 0.0, 0.0, 1.0 );
	
	// Normalized vector to target
	var vec = vector_to_point( from, to );
	
	// Quaternion to target vector
	var rot1 = quaternion_create_vector_difference( v_forward, vec );
	
	// Failure
	//if ( rot1 == -1 ) return -1;
	
	// Calculate up & right vectors if up direction is forced
	if ( force ) {
		
		var _right	= vector_cross( vec,	_up );
		_up			= vector_cross( _right, vec ); 
	
		var new_up = vector_rotate_quaternion( v_up, rot1 ); // matrix_vector( rot1.Matrix(), v_up );
	
		var rot2 = quaternion_create_vector_difference( new_up, _up );
		
		// Failure
		//if ( rot2 == -1 ) return -1;
		
		return quaternion_multiply( rot1, rot2 );
	}
	
	return rot1;
	
	
	
}

//http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-17-quaternions/#how-do-i-create-a-quaternion-in-glsl-
/// @function quaternion_create_vector_difference( vec1, vec2 )
function quaternion_create_vector_difference( vec1, vec2 ) {
	
	gml_pragma( "forceinline" );
	
	static v_forward	= new Vector3( 1.0, 0.0, 0.0 );
	static v_up			= new Vector3( 0.0, 0.0, 1.0 );
	static v_right		= new Vector3( 0.0, 1.0, 0.0 );
	
	var start	= vec1.Normalized();
	var dest	= vec2.Normalized();

	var cosTheta = vector_dot( start, dest );
	var rotationAxis;
	
	global.debugValues[? "Theta" ] = cosTheta;
	

	if ( cosTheta < ( -1.0 + 0.001 )) {
		
		debug_log( "Negative theta: " + string( [ sign( cosTheta  ), cosTheta ] ));
		
		//return -1;
		
		// special case when vectors in opposite directions:
		// there is no "ideal" rotation axis
		// So guess one; any will do as long as it's perpendicular to start
		rotationAxis = vector_cross( start, v_forward );
		if ( rotationAxis.SqrMagnitude() < 0.01 ) { // bad luck, they were parallel, try again!
			rotationAxis = vector_cross( start, v_right );
		}
		
		rotationAxis.Normalize();
		return quaternion_create_axis_angle( rotationAxis, 180.0 );
		
	}
	
	rotationAxis = vector_cross( dest, start );

	var  s		= sqrt( ( 1.0 + cosTheta ) * 2.0 );
	var invs	= 1 / s;

	var q = new Quaternion( s * 0.5, rotationAxis.x * invs, rotationAxis.y * invs, rotationAxis.z * invs );
	//q.Normalize();
	
	return q;

	
}

/// @description quaternion_clone( quaternion );
/// @arg _quat
function quaternion_clone( _quat ) {

	var _w = _quat.w;
	var _x = _quat.x;
	var _y = _quat.y;
	var _z = _quat.z;

	return new Quaternion( _w, _x, _y, _z );


}

/// @function quaternion_dot( a, b ) {
function quaternion_dot( a, b ) {
	
	return ( a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w );
	
}

/// @function random_quaternion
function random_quaternion() {
	var quat = new Quaternion();
	
	var xr = random( 360 );
	var yr = random( 360 );
	var zr = random( 360 );
	
	quat = quaternion_rotate_x( quat, xr, true );
	quat = quaternion_rotate_y( quat, yr, true );
	quat = quaternion_rotate_z( quat, zr, true );
	
	return ( quat );
}

/// @function quaternion_equal
/// @param quat1
/// @param quat2
function quaternion_equal( q1, q2 ) {
	
	var w1 = q1.w;
	var x1 = q1.x;
	var y1 = q1.y;
	var z1 = q1.z;

	var w2 = q2.w;
	var x2 = q2.x;
	var y2 = q2.y;
	var z2 = q2.z;
	
	return ( w1 == w2 && x1 == x2 && y1 == y2 && z1 == z2 );


}

/// @function quaternion_identity();
function quaternion_identity() {
	return new Quaternion();
}

/// @function quaternion_transform_vector( )
/// @param quat		{Quaternion}
/// @param vec		{Vec3}
/// @param v_target	{Vec3}
function quaternion_transform_vector( q, v ) {
	
	
	static q_conjugate	= new Quaternion();
	static t			= new Vector3();
	q_conjugate.Set( q.w, -q.x, -q.y, -q.z );
	q = q_conjugate;
	
	t = vector_cross( q, v, t );
	t = vector_multiply( t, 2.0, t );
	
	var qt	= vector_multiply( t, q.w );
	t		= vector_cross( q, t, t );
	
	qt.Add( t );
	qt.Add( v );
	return qt;

	//var crossX = q.y * v.z - q.z * v.y + q.w * v.x;
	//var crossY = q.z * v.x - q.x * v.z + q.w * v.y;
	//var crossZ = q.x * v.y - q.y * v.x + q.w * v.z;
	//var r = new Vector3();
	//r.x = v.x + 2.0 * q.y * crossZ - q.z * crossY;
	//r.y = v.y + 2.0 * q.z * crossX - q.x * crossZ;
	//r.z = v.z + 2.0 * q.x * crossY - q.y * crossX;
	//return r;
	
	//static q_conjugate	= new Quaternion();
	//static qq			= new Quaternion();
	
	//q_conjugate.Set( q.w, q.x, q.y, q.z );
	//qq.Set( q.w, -q.x, -q.y, -q.z );
	
	//v.w = 0;	// [ 0, vx, vy, vz ];
	
	//var quat		= quaternion_multiply( qq, v );
	//quat			= quaternion_multiply( quat, q_conjugate );
	
	//return new Vector3( quat.x, quat.y, quat.z );
	
	
		
}

/// @function quaternion_lerp()
/// @param q1			{Quaternion}
/// @param q1			{Quaternion}
/// @param t			{Float}
/// @param normalize	{Bool}
function quaternion_lerp( q1, q2, t, norm = true, q_target = noone ) {
	
	var _w = lerp( q1.w, q2.w, t );	
	var _x = lerp( q1.x, q2.x, t );	
	var _y = lerp( q1.y, q2.y, t );	
	var _z = lerp( q1.z, q2.z, t );	
	
	if ( q_target == noone ) q_target = new Quaternion( _w, _x, _y, _z );
		
	q_target.Set( _w, _x, _y, _z );
	if ( norm ) q_target.Normalize();
	
	return q_target;
	
	
}