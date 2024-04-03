/// Vector function library by Oakleaff

include( "Vectors" );

/// @function Vector2
/// @param {Real}	x
/// @param {Real}	y
/// @return {Struct.Vector2}
function Vector2( xx = 0, yy = xx ) constructor { 

	x = xx;
	y = yy;
	
	length		= 0;
	sqrLength	= 0;
	
	// Zero vector
	/// @function Zero()
	static Zero = function() {
		x = 0;
		y = 0;
		return self;
	}
	
	
	/// @function Set
	/// @param	{Real|Struct.Vector3}	x_or_vector
	/// @param	{Real}					y
	/// @return {Struct.Vector3}
	static Set = function( xx = 0, yy = 0, zz = 0 ) {
	
		if ( is_struct( xx )) {
			x = xx.x;
			y = xx.y;
		}
		else {
			x = xx;
			y = yy;
		}
		
		return self;
		
	}

	// Normalize the vector
	/// @function Normalize()
	/// @return {Struct.Vector3}
	static Normalize = function() {
		var l = ( x * x + y * y );
		if ( l <= 0 || is_nan( l ) ) {
			x = 0;
			y = 0;
			
			length = 0;
		}
		else {
			l = sqrt( l );
			x /= l;
			y /= l;
			
			length = 1;
		}
		
		return self;
	}
	
	// Return normalized vector
	/// @function Normalized()
	/// @return {Struct.Vector3}
	static Normalized = function() {
		
		var l = Magnitude();
		if ( l == 0 ) {
			return new Vector2( 0, 0 );
		}
		
		return new Vector2( x / l, y / l );
	}
	
	// Multiply by scalar
	/// @function Multiply( scalar )
	/// @return {Struct.Vector3}
	static Multiply = function( scalar ) {
		
		// Vector * vector
		if ( is_struct( scalar )) {
			x *= scalar.x;
			y *= scalar.y;
		}
		// Vector * matrix
		else if ( is_array( scalar )) {
			
			var vec = matrix_vector( scalar, x, y, 0 );
			x = vec.x;
			y = vec.y;
		}
		// Vector * scalar
		else {
			x *= scalar;
			y *= scalar;
		}
		
		return self;
	}
	
	// Get magnitude
	/// @function Magnitude()
	/// @return {Real}
	static Magnitude = function() {
		
		var l = ( x * x + y * y );
		return sqrt ( l );
	}
	
	// Square magnitude
	/// @function SqrMagnitude();
	/// @return {Real}
	static SqrMagnitude = function() {
		var l		= ( x * x + y * y );
		sqrLength	= l;
		return sqrLength;
	}
	

	
	// Get Array
	/// @function GetArray()
	/// @return {Array<Real>}
	static GetArray = function() {
		return [x, y];
	}
	
	/// @function Add( vec2 )
	/// @return {Struct.Vector2}
	static Add = function( _other ) {
		x += _other.x;
		y += _other.y;
	
		return self;
	}
	
	/// @function Subtract( vec2 )
	/// @return {Struct.Vector2}
	static Subtract = function( _other ) {
		x -= _other.x;
		y -= _other.y;
		return self;
	}
	
	/// @function Sub( vec3 )
	/// @return {Struct.Vector2}
	static Sub = function( _other ) {
		x -= _other.x;
		y -= _other.y;
		return self;
	}
	
	/// @function Clone() {
	/// @return {Struct.Vector2}
	static Clone = function() {
	
		return new Vector3( x, y );
	}
	
	
	/// @function Limit( value, smoothing )
	/// @return {Struct.Vector2}
	static Limit = function( value, smoothing = 1.0 ) {
	
		if ( SqrMagnitude() > sqr( value )) {
			
			if ( smoothing < 1.0 ) {
				var vec = Clone();
				vec.Normalize();
				vec.Multiply( value );
			
				x = lerp( x, vec.x, smoothing );
				y = lerp( y, vec.y, smoothing );
			}
			else {
				Normalize();
				Multiply( value );
			}
			
		}
		
		return self;
	
	}	
	
	/// @function Lerp( vec, t );
	/// @return {Struct.Vector2}
	static Lerp = function( vec, t ) {
		
		x = lerp( x, vec.x, t );	
		y = lerp( y, vec.y, t );		
		
		return self;
	}
	
	
	return self;
	
}


/// @function Vector3
/// @param {Real}	x
/// @param {Real}	y
/// @param {Real}	z
/// @return {Struct.Vector3}
function Vector3( xx = 0, yy = xx, zz = xx ) : Vector2( xx, yy ) constructor { 

	x = xx;
	y = yy;
	z = zz;
	
	length		= 0;
	sqrLength	= 0;
	
	// Zero vector
	/// @function Zero()
	static Zero = function() {
		x = 0;
		y = 0;
		z = 0;
		
		return self;
	}
	
	
	/// @function Set
	/// @param	{Real|Struct.Vector3}	x_or_vector
	/// @param	{Real}					y
	/// @param	{Real}					z
	/// @return {Struct.Vector3}
	static Set = function( xx = 0, yy = 0, zz = 0 ) {
	
		if ( is_struct( xx )) {
			x = xx.x;
			y = xx.y;
			z = xx.z;
		}
		else {
			x = xx;
			y = yy;
			z = zz;
		}
		
		return self;
		
	}

	// Normalize the vector
	/// @function Normalize()
	/// @return {Struct.Vector3}
	static Normalize = function() {
		var l = ( x * x + y * y + z * z );
		if ( l <= 0 || is_nan( l ) ) {
			
			x = 0;
			y = 0;
			z = 0;
			
			length = 0;
		}
		else {
			l = sqrt( l );
			x /= l;
			y /= l;
			z /= l;
			
			length = 1;
		}
		
		return self;
	}
	
	// Return normalized vector
	/// @function Normalized()
	/// @return {Struct.Vector3}
	static Normalized = function() {
		
		var l = Magnitude();
		if ( l == 0 ) {
			return new Vector3( 0, 0, 0 );
		}
		
		return new Vector3( x / l, y / l, z / l );
	}
	
	// Multiply by scalar
	/// @function Multiply( scalar )
	/// @return {Struct.Vector3}
	static Multiply = function( scalar ) {
		
		// Vector * vector
		if ( is_struct( scalar )) {
			x *= scalar.x;
			y *= scalar.y;
			z *= scalar.z;
		}
		// Vector * matrix
		else if ( is_array( scalar )) {
			
			var vec = matrix_vector( scalar, x, y, z );
			x = vec.x;
			y = vec.y;
			z = vec.z;
		}
		// Vector * scalar
		else {
			x *= scalar;
			y *= scalar;
			z *= scalar;
		}
		
		return self;
	}
	
	// Get magnitude
	/// @function Magnitude()
	/// @return {Real}
	static Magnitude = function() {
		
		var l = ( x * x + y * y + z * z );
		
		if ( l <= 0 ) {
			return 0;
		}
		
		return sqrt ( l );
	}
	
	// Square magnitude
	/// @function SqrMagnitude();
	/// @return {Real}
	static SqrMagnitude = function() {
		var l		= ( x * x + y * y + z * z );
		sqrLength	= l;
		return sqrLength;
	}
	
	/// @function Cross( vec )
	/// @param			vec2
	/// @return {Struct.Vector3}
	static Cross = function( vec2 ) {
		
		var ax = x;
		var ay = y;
		var az = z;

		var bx = vec2.x;
		var by = vec2.y;
		var bz = vec2.z;
	
		x = ay * bz - az * by; //0
		y = az * bx - ax * bz;	// -1
		z = ax * by - ay * bx; // 0

		return self;

	}
	
	
	// Get Array
	/// @function GetArray()
	/// @return {Array<Real>}
	static GetArray = function() {
		return [x, y, z];
	}
	
	/// @function Add( vec3 )
	/// @return {Struct.Vector3}
	static Add = function( _other ) {
		x += _other.x;
		y += _other.y;
		z += _other.z;
		
		return self;
	}
	
	/// @function Subtract( vec3 )
	/// @return {Struct.Vector3}
	static Subtract = function( _other ) {
		x -= _other.x;
		y -= _other.y;
		z -= _other.z;
		
		return self;
	}
	
	/// @function Sub( vec3 )
	/// @return {Struct.Vector3}
	static Sub = function( _other ) {
		x -= _other.x;
		y -= _other.y;
		z -= _other.z;
		
		return self;
	}
	
	/// @function Clone() {
	/// @return {Struct.Vector3}
	static Clone = function() {
	
		return new Vector3( x, y, z );
	}
	
	
	/// @function Limit( value, smoothing )
	/// @return {Struct.Vector3}
	static Limit = function( value, smoothing = 1.0 ) {
	
		if ( SqrMagnitude() > sqr( value )) {
			
			if ( smoothing < 1.0 ) {
				var vec = Clone();
				vec.Normalize();
				vec.Multiply( value );
			
				x = lerp( x, vec.x, smoothing );
				y = lerp( y, vec.y, smoothing );
				z = lerp( z, vec.z, smoothing );
			}
			else {
				Normalize();
				Multiply( value );
			}
			
		}
		
		return self;
	
	}	
	
	/// @function Lerp( vec, t );
	/// @return {Struct.Vector3}
	static Lerp = function( vec, t ) {
		
		x = lerp( x, vec.x, t );	
		y = lerp( y, vec.y, t );	
		z = lerp( z, vec.z, t );	
		
		return self;
	}
	
	
	return self;
	
}


/// @function		vector_dot
/// @param			vec1
/// @param			vec2
function vector_dot( vec1, vec2 ) {
	//var dot = ( vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z );
	return dot_product_3d( vec1.x, vec1.y, vec1.z, vec2.x, vec2.y, vec2.z ) ;

}

/// @function		vector_cross
/// @param			vec1
/// @param			vec2
/// @param			v_target
function vector_cross( a, b, v_target = noone ) {
	
	gml_pragma( "forceinline" );
	
	if ( v_target == noone ) v_target = new Vector3();
	
	var xx = a.y * b.z - a.z * b.y; //0
	var yy = a.z * b.x - a.x * b.z;	//-1
	var zz = a.x * b.y - a.y * b.x; //0

	v_target.Set( xx, yy, zz );
	return v_target;
}

/// @function		vector_to_point
/// @param			x1_or_vec
/// @param			y1_or_vec
/// @param			z1_or_normalize
/// @param			x2
/// @param			y2
/// @param			z2
/// @param			normalize
function vector_to_point( x1, y1, z1 = true, x2 = 0, y2 = 0, z2 = 0, norm = true ) {
	
	gml_pragma( "forceinline" );
	
	if ( is_struct( x1 ) && is_struct( y1 )) {
		
		var v1	= x1;
		var v2	= y1;
		norm	= z1;
		
		x1 = v1.x;
		y1 = v1.y;
		z1 = v1.z;
		x2 = v2.x;
		y2 = v2.y;
		z2 = v2.z;
	}
	
	var vec = new Vector3( x2 - x1, y2 - y1, z2 - z1 );
	
	if ( norm ) {
		vec.Normalize();
	}
	
	return( vec );
}

/// @function vector_add( vec1, vec2 ) 
/// @param			vec1
/// @param			vec2
/// @param			v_target
function vector_add( vec1, vec2, v_target = noone ) {

	if ( v_target == noone ) v_target = new Vector3();
	v_target.Set( vec1.x + vec2.x, vec1.y + vec2.y, vec1.z + vec2.z ); 
	return v_target;
	
}

/// @function vector_subtract( vec1, vec2 ) 
/// @param			vec1
/// @param			vec2
/// @param			v_target
function vector_subtract( vec1, vec2, v_target = noone ) {

	if ( v_target == noone ) v_target = new Vector3();
	v_target.Set( vec1.x - vec2.x, vec1.y - vec2.y, vec1.z - vec2.z ); 
	return v_target;
	
}

/// @function		vector_multiply
/// @param			vec1
/// @param			vec2_scalar_matrix
/// @param			v_target
function vector_multiply( vec1, vec2, v_target = noone ) {

	gml_pragma( "forceinline" );

	if ( v_target == noone ) v_target = new Vector3();

	var xx, yy, zz;
	
	// Vector * vector
	if ( is_struct( vec2 )) {
		xx = vec1.x * vec2.x;
		yy = vec1.y * vec2.y;
		zz = vec1.z * vec2.z;
	}
	// Vector * matrix
	else if ( is_array( vec2 )) {
			
		return matrix_vector( vec2, vec1.x, vec1.y, vec1.z );
	}
	// Vector * scalar
	else {
		xx = vec1.x * vec2;
		yy = vec1.y * vec2;
		zz = vec1.z * vec2;
	}
	
	v_target.Set( xx, yy, zz );
	return v_target;
}

/// @function		vector_lerp
/// @param	vec1
/// @param	vec2
/// @param	val
/// @param	dt
function vector_lerp( vec1, vec2, val = 0.5, dt = 1 ) {
	
	var xx = lerp( vec1.x, vec2.x, val );
	var yy = lerp( vec1.y, vec2.y, val );
	var zz = lerp( vec1.z, vec2.z, val );
	
	return new Vector3( xx, yy, zz );
}

/// @function		vector_angle
/// @param			vec1
/// @param			vec2
function vector_angle( vec1, vec2 ) {
	
	var theta;
	var dot     = vector_dot( vec1, vec2 );
	var mag1    = vec1.SqrMagnitude();
	var mag2    = vec2.SqrMagnitude();
	
	if ( mag1 == 0 || mag2 == 0 ) {
		return 0;
	}
	
	mag1 = sqrt( mag1 );
	mag2 = sqrt( mag2 );
	
	theta = darccos( clamp( dot / ( mag1 * mag2 ), -1, 1 ));

	return( theta );
}

/// @function		vector_angle_signed
/// @param			vec1	{Vec3}
/// @param			vec2	{Vec3}
/// @param			normal	{Vec3}
function vector_angle_signed( vec1, vec2, normal ) {
	
	static _cross_target = new Vector3();
	
	var _angle = vector_angle( vec1, vec2 );
	
	_cross_target = vector_cross( vec1, vec2, _cross_target );
	var _dot = vector_dot( _cross_target, normal );
	
	var _sign = sign( _dot );
	
	return _angle * _sign;
	
	
}


/// @function vector_rotate( vector, angle ) {
function vector_rotate( vector, angle ) {
	
	var matrix = matrix_build( 0, 0, 0, 0, 0, angle, 1, 1, 1 );
	
	return matrix_vector( matrix, vector.x, vector.y, vector.z );
}


/// @function vector_rotate_axis( vector, axis, angle );
function vector_rotate_axis( vector, axis, theta ) {
	
	var xx = vector.x;
	var yy = vector.y;
	var zz = vector.z;
	
	var u = axis.x;
	var v = axis.y;
	var w = axis.z;
	
	var ux = u * xx;
	var vy = v * yy;
	var wz = w * zz;
	
	var cos_theta = dcos( theta );
	var sin_theta = dsin( theta );
	
	var xPrime = u * ( ux + vy + wz ) * ( 1 - cos_theta ) 
	                + xx * cos_theta
	                + ( -w * yy + v * zz ) * sin_theta;
	var yPrime = v * ( ux + vy + wz ) * ( 1 - cos_theta )
	                + yy * cos_theta
	                + ( w * xx - u * zz ) * sin_theta;
	var zPrime = w * ( ux + vy + wz ) * ( 1 - cos_theta )
	                + zz * cos_theta
	                + ( -v * xx + u * yy ) * sin_theta;
					
					
	return new Vector3( xPrime, yPrime, zPrime );
}

//https://gamedev.stackexchange.com/questions/28395/rotating-vector3-by-a-quaternion
/// @function vector_rotate_quaternion( vector, quaternion ) {
/// @param vector		{Vec3}
/// @param quaternion	{Quaternion} 
function vector_rotate_quaternion( vector = new Vector3( 1, 0, 0 ), quaternion ) {
	
	//var v = vector;
	//var q = quaternion;
	
    //// Extract the vector part of the quaternion
    //var u = q;//new Vector3( q.x, q.y, q.z );

    //// Extract the scalar part of the quaternion
    //var s = q.w;

    //// Do the math
	//// vprime = 2.0 * dot(u, v) * u + (s*s - dot(u, u)) * v + 2.0 * s * Cross(u, v);
	
	//var uv			= vector_dot( u, v ) * 2.0;
	////var uu			= vector_dot( u, u ); --> further optimized into ( 2 * s * s - 1 )
	//var ss			= s * s * 2.0 - 1.0;
	//var s2			= s * 2.0;
	//var uv_cross	= vector_cross( u, v );
	
    //var vprime = new Vector3();
	////vprime.x = 2.0 * uv * u.x + ( ss - uu ) * v.x + s2 * uv_cross.x;
	////vprime.y = 2.0 * uv * u.y + ( ss - uu ) * v.y + s2 * uv_cross.y;
	////vprime.z = 2.0 * uv * u.z + ( ss - uu ) * v.z + s2 * uv_cross.z;
	
	//vprime.x = uv * u.x + ( ss ) * v.x + s2 * uv_cross.x;
	//vprime.y = uv * u.y + ( ss ) * v.y + s2 * uv_cross.y;
	//vprime.z = uv * u.z + ( ss ) * v.z + s2 * uv_cross.z;
	
	//return vprime;
	
	
	// Alternative - marginally faster ( 10fps at 5000 repeats/200fps )
	// https://pastebin.com/fAFp6NnN
	var value = vector;
	var quat	= quaternion_get_conjugate( quaternion );
    var num12	= quat.x + quat.x;
    var num2	= quat.y + quat.y;
    var num		= quat.z + quat.z;
    var num11	= quat.w * num12;
    var num10	= quat.w * num2;
    var num9	= quat.w * num;
    var num8	= quat.x * num12;
    var num7	= quat.x * num2;
    var num6	= quat.x * num;
    var num5	= quat.y * num2;
    var num4	= quat.y * num;
    var num3	= quat.z * num;
    var num15	= (( value.x * ((1 - num5) - num3)) + (value.y * (num7 - num9))) + (value.z * (num6 + num10));
    var num14	= (( value.x * (num7 + num9)) + (value.y * ((1 - num8) - num3))) + (value.z * (num4 - num11));
    var num13	= (( value.x * (num6 - num10)) + (value.y * (num4 + num11))) + (value.z * ((1 - num8) - num5));
    var X	= num15;
    var Y	= num14;
    var Z	= num13;
	
    return new Vector3( X, Y, Z );
}


/// @function vector_rotate_towards( vec1, vec2, angle )
/// @param {Struct.Vector3}		vec1
/// @param {Struct.Vector3}		vec2
/// @param {Real}				angle
function vector_rotate_towards( vec1, vec2, angle ) {
	
	var _axis = vector_cross( vec1, vec2 ).Normalized();
	var _angle = vector_angle_signed( vec1, vec2, _axis );
	
	_angle = min( abs( _angle ), angle ) * sign( _angle );
	
	return vector_rotate_axis( vec1, _axis, _angle );
	
}

/// @function		matrix_vector
/// @param {Array<Real>}			mat
/// @param {Real|Struct.Vector3}	_x_or_vec
/// @param {Real}					_y
/// @param {Real}					_z
function matrix_vector( mat, _x = 1, _y = 0, _z = 0 ) {
	
	var vec;
	if ( !is_struct( _x ) ) {
		vec = matrix_transform_vertex( mat, _x, _y, _z );
	}
	else vec = matrix_transform_vertex( mat, _x.x, _x.y, _x.z );
	
	return new Vector3( vec[0], vec[1], vec[2] );
}

/// @function random_vector
function random_vector() {
	var xx = random_range( -1, 1 );
	var yy = random_range( -1, 1 );
	var zz = random_range( -1, 1 );
	
	var vec = new Vector3( xx, yy, zz );
	vec.Normalize();
	
	return ( vec );
}

/// @function vector3_equals
/// @param v1
/// @param v2
function vector3_equals( v1, v2 ) {
	
	var x1 = v1.x;
	var y1 = v1.y;
	var z1 = v1.z;

	var x2 = v2.x;
	var y2 = v2.y;
	var z2 = v2.z;
	
	return ( x1 == x2 && y1 == y2 && z1 == z2 );


}

/// @function vector_reflect( v, n )
function vector_reflect( v, n ) {
	
	// r = 2 * ( v . n ) * n - v
	// r = v - 2*(v.n)*n
	
	var r	= new Vector3();
	var dot = vector_dot( v, n );
	
	//r.x = 2 * dot * nx - v.x;
	//r.y = 2 * dot * ny - v.y;
	//r.z = 2 * dot * nz - v.z;
	
	r.x = v.x - 2 * dot * n.x;
	r.y = v.y - 2 * dot * n.y;
	r.z = v.z - 2 * dot * n.z;
	
	return r;
}

/// @function vector_equal( v, n, treshold )
function vector_equal( v, n, treshold = 0 ) {
	
	if ( treshold == 0 ) return ( v.x == n.x && v.y == n.y && v.z == n.z );
	
	if ( abs( v.x - n.x ) > treshold ) return false;
	if ( abs( v.y - n.y ) > treshold ) return false;
	if ( abs( v.z - n.z ) > treshold ) return false;
	
	return true;
}

/// @function vector_get_perpendicular( vec )
function vector_get_perpendicular( vec ) {
	
	var t = new Vector3( vec.z, vec.z, -vec.x - vec.y );
	
	if ( t.x == 0 && t.y == 0 && t.z == 0 ) {
		t = new Vector3( -vec.y - vec.z, vec.x, vec.x );
	}
	
	return t;
}

/// https://stackoverflow.com/questions/1171849/finding-quaternion-representing-the-rotation-from-one-vector-to-another
/// @function vector_get_orthogonal( vec )
function vector_get_orthogonal( vec ) {
	
	static v_x = new Vector3( 1.0, 0.0, 0.0 );
	static v_y = new Vector3( 0.0, 1.0, 0.0 );
	static v_z = new Vector3( 0.0, 0.0, 1.0 );
	
	
    var xx = abs( vec.x );
    var yy = abs( vec.y );
    var zz = abs( vec.z );

    var _other = xx < yy ? ( xx < zz ? v_x : v_z ) : ( yy < zz ? v_y : v_z );
    return vector_cross( vec, _other );
}

/// @function vector_distance( vec1, vec2 );
function vector_distance( vec1, vec2 ) {
	
	return point_distance_3d( vec1.x, vec1.y, vec1.z, vec2.x, vec2.y, vec2.z );
	
}

/// @function vector_sqr_distance( vec1, vec2 );
function vector_sqr_distance( vec1, vec2 ) {
	
	return square_distance_3d( vec1.x, vec1.y, vec1.z, vec2.x, vec2.y, vec2.z );
	
}

/// https://rosettacode.org/wiki/Find_the_intersection_of_a_line_with_a_plane#C#
/// @function vector_plane_intersection( pos, vec, plane_pos, plane_normal )
/// @param {Struct.Vector3}	pos					Origin of ray
/// @param {Struct.Vector3}	vec					Direction of ray
/// @param {Struct.Vector3}	plane_pos			Origin of plane
/// @param {Struct.Vector3}	plane_normal		Normal of plane
/// @return {Struct.Vector3}
function vector_plane_intersection( pos, vec, plane_pos, plane_normal ) {
	
	var diff	= vector_subtract( pos, plane_pos );
	var prod1	= vector_dot( diff, plane_normal );
	var prod2	= vector_dot( vec, plane_normal );
	var prod3	= prod1 / prod2;
	
	return vector_subtract( pos, vector_multiply( vec, prod3 ));
	
}