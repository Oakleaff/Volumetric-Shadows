/// Custom function library
include( "CustomFunctions" );


/// @function approach( a, b, amount );
/// @param a
/// @param b 
/// @param amount
function approach( a, b, amount = DELTA ) {

	if ( a < b ) {
		a = min( a + amount, b );
	}

	else {
		a = max( a - amount, b );
	}

	return ( a );
}

/// @function animcurve_evaluate( curve, channel, time ){
/// @param curve
/// @param channel
/// @param time
function animcurve_evaluate( curve, channel, time ){

	var _curve		= animcurve_get( curve );
	var _channel	= animcurve_get_channel( _curve, channel );
	var value		= animcurve_channel_evaluate( _channel, time );
	
	return value;

}

/// @function array_clone( array ) {
function array_clone( array ) {

	var new_array = [];
	
	array_copy( new_array, 0, array, 0, array_length( array ));
	
	return new_array;


}

/// @function array_find_value_index( array, val ) {
function array_find_value_index( array, value ) {
	
	var __len = array_length( array );
	if ( __len == 0 ) return -1;
	
	var __i;
	for ( __i = 0; __i < __len; __i ++ ) {
		var val = array[ __i ];
		if ( val == value ) return __i;
	}
	
	return -1;
}

/// @function array_to_ds_list( array ) {
function array_to_ds_list( array ) {

	var list	= ds_list_create();
	var num		= array_length( array );
	for ( var n = 0; n < num; n ++ ) ds_list_add( list, array[n] );
	
	return list;
	
	
}

/// @function array_last( array ) {
function array_last( array ) {

	return array[ array_length( array ) - 1 ];
}

/// @function array_random( array ) {
function array_random( array ) {
	
	return array[ irandom( array_length( array ) - 1 ) ];
	
}

/// @function ds_list_to_array( list ){
function ds_list_to_array( list ) {

	var array	= [];
	var num		= ds_list_size( list );
	for ( var n = 0; n < num; n ++ ) array[n] = list[| n ];
	
	return array;
	
	
}

/// @function avg( num1, num2, num3... );
function avg() {

	var num		= 0;

	for ( var i = 0; i < argument_count; i ++ ) {
		num += argument[i];
	}

	return ( num / argument_count );
}

/// @function avg_colour( col1, col2, col3... );
function avg_colour() {

	var num		= 0;
	var red		= 0;
	var green	= 0; 
	var blue	= 0;

	for ( var i = 0; i < argument_count; i ++ ) {
	
		num ++;
		red		+=	colour_get_red( argument[i] );
		green	+=	colour_get_green( argument[i] );
		blue	+=	colour_get_blue( argument[i] );
	}

	return ( make_colour_rgb( red / num, green / num, blue / num ));


}

/// @function audio_play_pitched( sound, priority, loops, minShift, maxShift );
function audio_play_pitched( sound, priority = 0, loops = false, minShift = 0, maxShift = 0 ) {

	var snd = audio_play_sound( sound, priority, loops );
	audio_sound_pitch( snd, 1 + random_range( minShift, maxShift ));

	return snd;
	
} 

/// @function bitmask( a, b);
function bitmask( a, b ) {
	
	//Return true for AND & equals
	return(  ( a & b ) > 0 || a == b );

}


/// @function clamp01( value )
function clamp01( value ) {
	
	return clamp( value, 0, 1 );	
	
}





/// @function ds_list_remove( list, pos );
/// @param list
/// @param pos
function ds_list_remove( list, pos = 0 ) {
	
	var val = list[| pos ];
	ds_list_delete( list, pos );
		
	return val;
}

/// @function ds_list_reverse( list )
function ds_list_reverse( list ) {
	
	var _len = ds_list_size( list );

	for( var i = _len - 1; i >= 0; i --) {
	    ds_list_add( list, list[| i] );
	}

	repeat( _len ) {
	    ds_list_delete( list, 0 );
	}
}

/// @function find_lca( array0, array1 )
// Find the Lowest Common Ancestor of two arrays
function find_lca( array0, array1 ) {
	
	var p = 0;
	var size = min( array_length( array0 ), array_length( array1 ));
	
	if ( size == 0 ) return noone;
	
	while( p < size && array0[p] == array1[p] ) p += 1;
	
	p = clamp( p, 0, size - 1 );
	
	if ( p > 0 ) {
		if ( array0[p] != array1[p] && array0[ p - 1 ] == array1[ p - 1 ] ) return array0[ p - 1 ];
	}
	if ( array0[p] == array1[p] ) return array0[ p ];
	
	return noone;
}

/// @function frac_get( num, index )
function frac_get( num, index ) {
	
	if ( index == 0 ) return floor( num ) - ( floor( num * 0.1 ) * 10 );
	
	
	return ( floor( num * power( 10, index )) - ( floor( num * power( 10, index - 1 )) * 10 ));
	
	
}

/// @function instance_check( inst )
/// @param instance
function instance_check( inst ) {
	
	if ( inst == noone || !instance_exists( inst )) return false;
	
	return true;
	
}

/// @description instance_nearest_nth(x, y, obj, n);
/// @param	x
/// @param  y
/// @param  obj
/// @param  n
function instance_nearest_nth( pointx, pointy, object, n ) {
	
	var list, nearest;
	n = min( max( 1, n ), instance_number( object ));
	if ( n == 1 ) {
		return ( instance_nearest( pointx, pointy, object ));
	}
		
	list = ds_priority_create();
	nearest = noone;
	with ( object ) {
		ds_priority_add( list, id, square_distance(x, y, pointx, pointy));
	}
	repeat (n) {
		nearest = ds_priority_delete_min(list);
	}
	ds_priority_destroy(list);
	return ( nearest );
}

/// @description instance_nearest_3d( x, y, z, obj, n);
function instance_nearest_3d( pointx, pointy, pointz, object, n = 1 ) {
	
	var list, nearest;
	n = clamp( n, 1, instance_number( object ));
	//if ( instance_number( object ) == 1 ) {
	//	return ( object );
	//}
		
	list	= ds_priority_create();
	nearest = noone;
	with ( object ) {
		ds_priority_add( list, id, square_distance_3d( x, y, z, pointx, pointy, pointz ));
	}
	repeat (n) {
		nearest = ds_priority_delete_min(list);
	}
	ds_priority_destroy(list);
	return ( nearest );

}

/// @description instance_create( x, y, object );
/// @param x1
/// @param y1
/// @param obj
function instance_create( xx, yy, obj ) {

	return ( instance_create_depth( xx, yy, 0, obj ));

}


/// @description instance_create( x, y, z, object );
/// @param x1
/// @param y1
/// @param z1
/// @param obj
function instance_create_3d( x1, y1, z1, obj ) {

	global.__z = z1;
	
	var o = instance_create_depth( x1, y1, 0, obj );
	o.z = global.__z;
	
	o.xstart = x1;
	o.ystart = y1;
	o.zstart = z1;

	return ( o );

}

/// @function instance_get_root_parent( inst ) {
function instance_get_root_parent( inst ) {
	
	if ( inst == noone ) return noone;

	var obj = inst.object_index;
	var par = object_get_parent( obj );
	
	if ( par == -100 ) return obj;			// No parent
	
	while ( object_get_parent( par ) >= 0 ) {
		par = object_get_parent( par );
	}
	
	return par;
	
}

/// @function inverse_lerp( a, b, value )
/// @param a
/// @param b
/// param value
function inverse_lerp( a, b, value ){
	return ( ( value - a ) / ( b -a ) );
}

/// @function inverse_power( value, pow ) {
function inverse_power( value, pow ) {

	return ( 1.0 - power( 1.0 - value, pow ));

}

// Check is value given is equal to type0 ... typeX
/// @function is_one_of( value, type0, type1... )
function is_one_of( ) {
	
	var val = argument[0];
	
	for ( var i = 1; i < argument_count; i ++ ) {
		if ( val == argument[ i ] ) return true;
	}
	
	return false;
		

}

/// @description lerp_delta( a, b, f, dt );
/// @arg a	{float}	Source value
/// @arg b	{float}	Target value
/// @arg f	{float} Smooth amount
/// @arg dt	{float}	Timestep
function lerp_delta( a, b, f, dt ) {
	
	var _f = 1.0 - f;	// Additive inverse so 0 = source value & 1 = target value
	//return ( lerp( a, b,  1.0 - power( _f, dt )));
	return lerp( a, b,  1.0 - exp( -f * dt ));


}

/// @function lerp_log( a, b, f, dt ) 
function lerp_log( a, b, f, dt ) {
	
	return lerp( a, b, power( 2, -f * dt ));
	
	
}

/// @function lerp_ext( a, b, amount, min, max );
/// @param
function lerp_ext( a, b, amount, _min, _max ){

	var diff = b - a;
	
	var lerpDiff = diff * amount;
	
	var lerpAmount = clamp( abs( lerpDiff ), _min, _max );
	
	return approach( a, b, lerpAmount );
	

}

/// @description lerp_angle(angle1, angle2, amount);
/// @param angle1
/// @param  angle2
/// @param  amount
function lerp_angle() { 
	var a1  = argument[0];
	var a2  = argument[1];
	var t   = argument[2];
 
	var diff = angle_difference(a1, a2);
	return ( a1 - diff * t );

}

/// @function make_colour( r, g, b )
function make_colour( r, g, b ) {
	return make_colour_rgb( r * 255, g * 255, b * 255 );
}

/// @function make_color( r, g, b )
function make_color( r, g, b ) {
	return make_colour_rgb( r * 255, g * 255, b * 255 );
}

/// @description modulo(a, b);
/// @param a
/// @param  b
function modulo( a, b ) {
	
	if ( b == 0 ) {
		return 0;
	}

	var t = a mod b;

	if ( a < 0 ) {
	    t = ( b - abs( a mod b )) mod b;
	}
    
	return ( t );

}

/// @desc		Remap a value from min_old...max_old to min_new...max_new
/// @function	remap_value( val, min_old, max_old, min_new, max_new )
/// @param		val
/// @param		min_old
/// @param		max_old
/// @param		min_new
/// @param		max_new
function remap_value( val, min_old = -1, max_old = 1, min_new = 0, max_new = 1 ) {
	
	var f = ( val - min_old ) / ( max_old - min_old );
	
	return lerp( min_new, max_new, f );
	
	
}

/// @function smoothstep( e0, e1, val )
/// @param e0
/// @param e1
/// @param val
function smoothstep( e0, e1, val ){

	// Scale, bias and saturate x to 0..1 range
	val = clamp(( val - e0 ) / ( e1 - e0 ), 0.0, 1.0 ); 
	
	// Evaluate polynomial
	return val * val * ( 3 - 2 * val );
}

/// @description square_distance(x1, y1, x2, y2);
/// @param x1
/// @param  y1
/// @param  x2
/// @param  y2
function square_distance( x1, y1, x2, y2 ) {
	//Squared distance = faster than point_distance
	var _x = abs( x2 - x1 );
	var _y = abs( y2 - y1 );

	return (_x * _x + _y * _y);

}

/// @description square_distance(x1, y1, z1, x2, y2, z2);
/// @param	x1
/// @param  y1
/// @param  z1
/// @param  x2
/// @param  y2
/// @param  z2
function square_distance_3d(x1, y1, z1, x2, y2, z2) {
	//Squared distance = faster than point_distance
	var _x = abs( x2 - x1 );
	var _y = abs( y2 - y1 );
	var _z = abs( z2 - z1 );

	return ( _x * _x + _y * _y + _z * _z );



}

/// @description point_direction_3d(x1, y1, z1, x2, y2, z2);
/// @param x1
/// @param  y1
/// @param  z1
/// @param  x2
/// @param  y2
/// @param  z2
function point_direction_3d( x1, y1, z1, x2, y2, z2 ) {
	//outputs an array with 2 values

	var ret;
	ret[0] = 0;
	ret[1] = 0;
	
	ret[0]	= point_direction( x1, y1, x2, y2 );
	var len = point_distance( x1, y1, x2, y2 );

	ret[1]	= point_direction( 0, z1, len, z2 ); 

	return new Vector3( ret[0], ret[1] );



}

/// @function split_value( value, parts, min_split, max_split ) {
function split_value( value = 10, parts = 2, min_split = 0, max_split = 5 ) {

	var n = value;
    var result = [];
	var v;
	
	var min_v = ( value / parts ) * 0.2;
	var max_v = ( value / parts ) * 1.8;
	var tries = 0;
	var max_tries = 100;
    for ( var i = 0; i < parts - 1; i ++ ) {
		
        v = irandom_range( 1, n - parts + i + 1 );
		if ( min_split != 0 || max_split != 0 ) {
			v = clamp( v, min_split, max_split );
		}
		
		if ( v >= min_v && v <= max_v || tries > max_tries ) {
	        n -= v;
	        array_push( result, v );
		}
		else i --;
		
		tries ++;
	}
    array_push( result, n );
	
    return result;
}
/// @function ds_list_value_exists( list, value )
/// @param list
/// @param value
function ds_list_value_exists( list, value ) {
	
	return ( ds_list_find_index( list, value ) != -1 );
}

/// @function draw_set_align( halign, valign );
function draw_set_align( halign, valign ){

	draw_set_halign( halign );
	draw_set_valign( valign );
	
}

/// @function texture_get_uv_array( texture, flip_x, flip_y )
/// @description
function texture_get_uv_array( texture, flip_x = false, flip_y = false ){
	var uv = texture_get_uvs( texture );
	
	if ( flip_x ) {
		var x1 = uv[0];
		var x2 = uv[2];
		uv[0] = x2;
		uv[2] = x1;
	}
	if ( flip_y ) {
		var y1 = uv[1];
		var y2 = uv[3];
		uv[3] = y2;
		uv[1] = y1;
	}
		
	
	
	return [ uv[0], uv[1], uv[2], uv[3] ];
}



/// @function generate_staticIdentifier();
function generate_staticIdentifier() {
	
	var str =	string( current_year );
	str +=		string( current_month );
	str +=		string( current_weekday );
	str +=		string( current_day );
	str +=		string( current_hour );
	str +=		string( current_minute );
	str +=		string( current_second );
	str +=		string( current_time * pi );
	str =		string( current_time) + sha1_string_unicode( str );
	
	log( str );
	return str;
	
}


/// @function lines_intersect(x1,y1,x2,y2,x3,y3,x4,y4,segment)
//
//  Returns a vector multiplier (t) for an intersection on the
//  first line. A value of (0 < t <= 1) indicates an intersection 
//  within the line segment, a value of 0 indicates no intersection, 
//  other values indicate an intersection beyond the endpoints.
//
//      x1,y1,x2,y2     1st line segment
//      x3,y3,x4,y4     2nd line segment
//      segment         If true, confine the test to the line segments.
//
//  By substituting the return value (t) into the parametric form
//  of the first line, the point of intersection can be determined.
//  eg. x = x1 + t * (x2 - x1)
//      y = y1 + t * (y2 - y1)
//
/// GMLscripts.com/license
function lines_intersect( x1, y1, x2, y2, x3, y3, x4, y4, segment )
{
    var ua, ub, ud, ux, uy, vx, vy, wx, wy, _ud;
    ua = 0;
    ux = x2 - x1;
    uy = y2 - y1;
    vx = x4 - x3;
    vy = y4 - y3;
    wx = x1 - x3;
    wy = y1 - y3;
	
    ud = vy * ux - vx * uy;
    if (ud != 0) 
    {
		_ud = 1 / ud;
		
        ua = ( vx * wy - vy * wx ) * _ud;
        if ( segment ) 
        {
            ub = ( ux * wy - uy * wx ) * _ud;
            if (ua < 0 || ua > 1 || ub < 0 || ub > 1) ua = 0;
        }
    }
    return ua;
}


// Return point POS along line segment defined by (x1, y1) (x2, y2)
/// @function line_point( x1, y1, x2, y2, pos )
function line_point( x1, y1, x2, y2, pos ) {

	var xx = x1 + pos * ( x2 - x1 );
	var yy = y1 + pos * ( y2 - y1 );

	return new Vector3( xx, yy );
}

/// @function line_nearest_point( x1, y1, x2, y2, px, py );
/// @param x1	x1 point on line
/// @param y1	y1 point on line
/// @param x2	x2 point on line
/// @param y2	y2 point on line
/// @param px	x point to check
/// @param py	y point to check
function line_nearest_point( x1, y1, x2, y2, px, py ) {
	
	static req = require( "Vectors" );
	
	var s	= new Vector3( x2 - x1, y2 - y1 ).normalized();
	var dx	= s.x;
	var dy	= s.y;

    //var v = new Vector3( px - x1, py - y1 );
    var d = dot_product( px - x1, py - y1, dx, dy ); //   vector_dot( v, new Vector3( dx, dy ));
	
    return new Vector3( x1 + dx * d, y1 + dy * d );
	
}

/// @function line_nearest_point_segment( x1, y1, x2, y2, px, py );
/// @param x1	x1 point on line
/// @param y1	y1 point on line
/// @param x2	x2 point on line
/// @param y2	y2 point on line
/// @param px	x point to check
/// @param py	y point to check
function line_nearest_point_segment( x1, y1, x2, y2, px, py ) {
	
	static AB = new Vector3();
	static AP = new Vector3();
	
	AB.set( x2 - x1, y2 - y1 );
	AP.set( px - x1, py - y1 );
	
	var lengthSqrAB = AB.x * AB.x + AB.y * AB.y;
	var t = ( AP.x * AB.x + AP.y * AB.y ) / lengthSqrAB;
	
	t = clamp( t, 0, 1 );
	
	return [ x1 + t * AB.x, y1 + t * AB.y ];
	
}

// https://forum.unity.com/threads/how-do-i-find-the-closest-point-on-a-line.340058/
/// @function vector_nearest_point_on_line( line_pos, line_dir, pos ) {
/// @param line_pos	{Vec3}	Point on line
/// @param line_dir	{Vec3}	Direction of line ( normalized )
/// @param pos		{Vec3}	World space position to check
function vector_nearest_point_on_line( line_pos, line_dir, pos ) {
	
	static req = require( "Vectors" );
	static v = new Vector3();
	
	if ( line_dir.sqr_magnitude() != 1.0 ) line_dir.normalize();
	v.set( pos );
	v.subtract( line_pos );
	var d = vector_dot( v, line_dir );
	
	return line_pos.clone().add( line_dir.multiply( d ));
	
}


/// @function path_create( points, closed, smooth ) {
function path_create( points, closed = false, smooth = true ) {

	var pth = path_add();
	path_set_closed( pth,	closed );
	path_set_kind( pth,		smooth );

	var point;
	for ( var n = 0; n < array_length( points ); n ++ ) {
		
		point = points[n];
		
		if ( is_struct( point )) {
			path_add_point( pth, point.x, point.y, point.z );
		}
		else path_add_point( pth, point[0], point[1], point[2] );
		
		
	}

	return pth;

}


/// @function path_get_position( path, pos )
function path_get_position( path, pos ) {
	
	return [	path_get_x( path,		pos ),
				path_get_y( path,		pos ),
				path_get_speed( path,	pos ) ];
			
	
	
}
/// @function path_get_point( path, num )
function path_get_point( path, num ) {
	
	return [	path_get_point_x( path,		num ),
				path_get_point_y( path,		num ),
				path_get_point_speed( path, num ) ];
			
	
	
}

/// @function triangle_get_z( v0, v1, v2, px, py ) {
function triangle_get_z( v1, v2, v3, px, py ) {

	//var det = ( v2.y - v3.y ) * ( v1.x - v3.x ) + ( v3.x - v2.x ) * ( v1.y - v3.y );
	//var l1	= (( v2.y - v3.y ) * ( px - v3.x ) + ( v3.x - v2.x )  * ( py - v3.y )) / det;
	//var l2	= (( v3.y - v1.y ) * ( px - v3.x ) + ( v1.x - v3.x ) * ( py - v3.y )) / det;
	//var l3	= 1.0 - l1 - l2;
	
	//var val = l1 * v1.z + l2 * v2.z + l3 * v3.z;
	//var min_z = min( v1.z, v2.z, v3.z );
	//var max_z = max( v1.z, v2.z, v3.z );
	
	//return clamp( val, min_z, max_z );
	
	var dx1 = px - v1.x;
	var dy1 = py - v1.y;
	var dx2 = v2.x - v1.x;
	var dy2 = v2.y - v1.y;
	var dx3 = v3.x - v1.x;
	var dy3 = v3.y - v1.y;
	return  v1.z + ((dy1 * dx3 - dx1 * dy3) * (v2.z - v1.z) + (dx1 * dy2 - dy1 * dx2) * ( v3.z - v1.z)) / (dx3 * dy2 - dx2 * dy3);
   
}

/// @function triangle_get_values( v0, v1, v2, px, py ) {
function triangle_get_values( v1, v2, v3, px, py ) {

	var dx1 = px - v1.x;
	var dy1 = py - v1.y;
	var dx2 = v2.x - v1.x;
	var dy2 = v2.y - v1.y;
	var dx3 = v3.x - v1.x;
	var dy3 = v3.y - v1.y;
	
	var r1 = colour_get_red(	v1.colour );
	var g1 = colour_get_green(	v1.colour );
	var b1 = colour_get_blue(	v1.colour );
	var a1 = v1.alpha;
	
	var r2 = colour_get_red(	v2.colour );
	var g2 = colour_get_green(	v2.colour );
	var b2 = colour_get_blue(	v2.colour );
	var a2 = v2.alpha;
	
	var r3 = colour_get_red(	v3.colour );
	var g3 = colour_get_green(	v3.colour );
	var b3 = colour_get_blue(	v3.colour );
	var a3 = v3.alpha;
	
	var val1 = dy1 * dx3 - dx1 * dy3;
	var val2 = dx1 * dy2 - dy1 * dx2;
	var val3 = dx3 * dy2 - dx2 * dy3;
	
	
	var zz = v1.z + ( val1 * (v2.z - v1.z) +	val2 * ( v3.z - v1.z)) /	val3;
	var rr = r1 +	( val1 * ( r2 - r1 ) +		val2 * ( r3 - r1 )) /		val3;
	var gg = g1 +	( val1 * ( g2 - g1 ) +		val2 * ( g3 - g1 )) /		val3;
	var bb = b1 +	( val1 * ( b2 - b1 ) +		val2 * ( b3 - b1 )) /		val3;
	var aa = a1 +	( val1 * ( a2 - a1 ) +		val2 * ( a3 - a1 )) /		val3;
	
	return [ zz, rr, gg, bb, aa ];
   
}


/// @function world_to_screen( x, y, z, view_mat, proj_mat, width, height );
/// @param xx
/// @param yy
/// @param zz
/// @param view_mat
/// @param proj_mat
/// @param screen_width
/// @param screen_height
/*
    Transforms a 3D world-space coordinate to a 2D window-space coordinate. Returns an array of the following format:
    [xx, yy]
    Returns [-1, -1] if the 3D point is not in view
   
    Script created by TheSnidr
    www.thesnidr.com
*/
function world_to_screen( xx, yy, zz, view_mat = Camera.view_mat, proj_mat = Camera.proj_mat, width = window_get_width(), height = window_get_height() ) {

	var vec = new Vector3();

	if ( proj_mat[15] == 0 ) {   //This is a perspective projection
		
	    var w = view_mat[2] * xx + view_mat[6] * yy + view_mat[10] * zz + view_mat[14];
	    // If you try to convert the camera's "from" position to screen space, you will
	    // end up dividing by zero (please don't do that)
	    //if (w <= 0) return [-1, -1];
	    if ( w <= 0 ) vec.z = -1; //return new Vector3( -1, -1 );
		
	    var cx = proj_mat[8] + proj_mat[0] * (view_mat[0] * xx + view_mat[4] * yy + view_mat[8] * zz + view_mat[12]) / w;
	    var cy = proj_mat[9] + proj_mat[5] * (view_mat[1] * xx + view_mat[5] * yy + view_mat[9] * zz + view_mat[13]) / w;
	} else {    //This is an ortho projection
	    var cx = proj_mat[12] + proj_mat[0] * (view_mat[0] * xx + view_mat[4] * yy + view_mat[8]  * zz + view_mat[12]);
	    var cy = proj_mat[13] + proj_mat[5] * (view_mat[1] * xx + view_mat[5] * yy + view_mat[9]  * zz + view_mat[13]);
	}

	var rx = ( 0.5 + 0.5 * cx ) * width;
	var ry = ( 0.5 + 0.5 * cy ) * height;
	
	vec.x = rx;
	vec.y = ry;
	
	return vec;
}

/// @function screen_to_world(x, y, view_mat, proj_mat)
/// @param x
/// @param y
/// @param view_mat
/// @param proj_mat
/// @param screen_width
/// @param screen_height
/*
Transforms a 2D coordinate (in window space) to a 3D vector.
Returns an array of the following format:
[ vec(dx, dy, dz), vec3(ox, oy, oz) ]
where vec3(dx, dy, dz) is the direction vector and vec3(ox, oy, oz) is the origin of the ray.
Works for both orthographic and perspective projections.
Script created by TheSnidr
(slightly modified by @dragonitespam)
*/
function screen_to_world( _x, _y, V, P, width = window_get_width(), height = window_get_height() ) {
	
	var mx = 2 * (_x / width - 0.5) / P[0];
	var my = 2 * (_y / height - 0.5) / P[5];
	var camX = - ( V[12] * V[0] + V[13] * V[1] + V[14] * V[2] );
	var camY = - ( V[12] * V[4] + V[13] * V[5] + V[14] * V[6] );
	var camZ = - ( V[12] * V[8] + V[13] * V[9] + V[14] * V[10] );

	//This is a perspective projection
	if ( P[15] == 0 ){    
	    return [	new Vector3(	V[2]  + mx * V[0] + my * V[1],
									V[6]  + mx * V[4] + my * V[5],
									V[10] + mx * V[8] + my * V[9] ),
					new Vector3(	camX,
									camY,
									camZ )];
	}
	//This is an ortho projection
	else
	{    
	    return [	new Vector3(	V[2],
									V[6],
									V[10] ),
					new Vector3(	camX + mx * V[0] + my * V[1],
									camY + mx * V[4] + my * V[5],
									camZ + mx * V[8] + my * V[9] )];
	}

}

/// @function sprite_get_size( spr, img );
function sprite_get_size( spr, img = 0 ) {
	
	var tex = sprite_get_texture( spr, img );
	
	var _texPageWidth	= 1.0 / texture_get_texel_width( tex );
	var _texPageHeight	= 1.0 / texture_get_texel_height( tex );
	
	var uvs = texture_get_uvs( tex );
	
	var w = uvs[2] - uvs[0];
	var h = uvs[3] - uvs[1];
	
	w *= _texPageWidth;
	h *= _texPageHeight;
	
	return [ w, h ];

}


// Reads all real values from a line separated by sepearator and returns them as an array
/// @function string_parse_values()
/// @param string
/// @param separator
function string_parse_values( str, separator ) {
		
	var arr = [];
		
	// Remove space at start
	if ( string_char_at( str, 1 ) == " " ) str = string_copy( str, 2, string_length( str ) - 1 );
		
	// Replace spaces with | & add one to the end
	str = string_replace_all( str, separator, "|" );
	str = string_replace( str, str, str + "|" );
		
	var pos, char_at, i, value;
	pos		= 1;
	i		= 0;
	value	= 0;
	while ( string_length( str ) > 0 ) {
			
		char_at = string_char_at( str, pos );
		if ( char_at == "|" ) { // Value end character
				
			// Copy characters up to the line end character
			value = string_copy( str, 1, pos - 1 );
			//value = real( value );
				
			arr[ i++ ] = value;
			
			// Delete read value from string
			str = string_delete( str, 1, pos );
			pos = 1;
		}
		pos ++;
	}
	return arr;
}


/// @function string_fill( filler, str ) {
function string_fill( filler, str ) {
	
	var len0 = string_length( filler );
	var len1 = string_length( str );
	
	var len = len0 - len1;
	if ( len > 0 ) {
		
		str = string_insert( string_copy( filler, 1, len ), str, 1 );
	}
	
	return str;
	
	
}

/// @function matrix_transform( x, y, z, xrot, yrot, zrot, xscale, yscale, zscale);
/// @param {Real|Array}	x_or_matrix
/// @param				y
/// @param				z
/// @param				xrot
/// @param				yrot
/// @param				zrot
/// @param				xscale
/// @param				yscale
/// @param				zscale
function matrix_transform( xx = 0, yy = 0, zz = 0, xrot = 0, yrot = 0, zrot = 0, xscale = 1, yscale = 1, zscale = 1 ) {

	var mat;
	if ( is_array( xx ) && array_length( xx ) == 16 ) {
		mat = xx;
	}
	else mat = matrix_build( xx, yy, zz, xrot, yrot, zrot, xscale, yscale, zscale );
	
	matrix_set( matrix_world, mat );

}

/// @function matrix_create()
function matrix_create( xx = 0, yy = 0, zz = 0, xrot = 0, yrot = 0, zrot = 0, xscale = 1, yscale = 1, zscale = 1 ) {

	return matrix_build( xx, yy, zz, xrot, yrot, zrot, xscale, yscale, zscale );

}

/// @function matrix_transform_scale( x, y, z, xrot, yrot, zrot, xscale, yscale, zscale);
/// @param matrix
/// @param xscale
/// @param yscale
/// @param zscale
function matrix_transform_scale( mat = matrix_build_identity(), xscale = 1, yscale = undefined, zscale = undefined ) {

	if ( is_undefined( yscale )) yscale = xscale;
	if ( is_undefined( zscale )) zscale = xscale;

	var _scale_matrix = matrix_build( 0, 0, 0, 0, 0, 0, xscale, yscale, zscale );

	matrix_set( matrix_world, matrix_multiply( _scale_matrix, mat ));

}

/// @matrix_transform_quaternion( x, y, z, quat );
/// @param x
/// @param y
/// @param z
function matrix_transform_quaternion( xx = 0, yy = 0, zz = 0, quat ) {
	
	var pos = matrix_build( xx, yy, zz, 0, 0, 0, 1, 1, 1 );
	
	matrix_transform( matrix_multiply( quat.matrix(), pos ));
	
}
	

/// @function matrix_reset()
function matrix_reset() {
	
	static mat = matrix_build_identity();
	
	matrix_set( matrix_world, mat );
	
}


// Check all triangles of a polygon
/// @function __point_in_polygon( px, py, polygon, bias ) {
function __point_in_polygon( px, py, polygon, bias = 1.0 ) {
	
	if ( !is_struct( polygon )) return false;
	
	
	if ( polygon.triangulated ) {
		var tris	= polygon.triangles;
		var num		= array_length( tris );
	
		if ( num == 0 ) return false;
	
	
		for ( var n = 0; n < num; n ++ ) {
			var triangle = tris[n];
			
			var x1 = triangle.vert[0].x;
			var y1 = triangle.vert[0].y;
			var x2 = triangle.vert[1].x;
			var y2 = triangle.vert[1].y;
			var x3 = triangle.vert[2].x;
			var y3 = triangle.vert[2].y;
			
			// Add overlap to triangles
			if ( bias != 1.0 ) {
				x2 = lerp( triangle.vert[2].x, x2, bias );
				y2 = lerp( triangle.vert[2].y, y2, bias );
				x3 = lerp( triangle.vert[1].x, x3, bias );
				y3 = lerp( triangle.vert[1].y, y3, bias );
			}
			
			if ( point_in_triangle( px, py, x1, y1, x2, y2, x3, y3 )) {
				return true;
			}
		}
	}
	else {
		var verts	= polygon.vertices;
		var num		= array_length( verts );
	
		if ( num == 0 ) return false;
	
		// Calculate rough polygon center (average)
		var pos = new Vector3();
		for ( var n = 0; n < num; n ++ ) {
			pos.x += verts[n].x;
			pos.y += verts[n].y;
		}
		pos.multiply( 1.0 / num );
			
			
		for ( var n = 0; n < num; n ++ ) {
			var v0 = verts[n];
			var v1 = verts[ ( n + 1 ) mod num ];
		
			if ( point_in_triangle( px, py, pos.x, pos.y, v0.x, v0.y, v1.x, v1.y )) {
				return true;
			}
		}
		
		
		
	}
	
	
	return false;
}


/// @function point_in_polygon( x, y, polygon )
//
//  Returns true if the given test point is inside 
//  the given 2D polygon, false otherwise.
//
//      x,y         coordinates of the test point
//      polygon     ds_list of an ordered series of coordinate 
//                  pairs defining the shape of a polygon
//
//  Polygons are closed figures with edges spanning consecutive
//  vertices and from the last vertex to the first.
//
/// GMLscripts.com/license
function point_in_polygon( x0, y0, polygon )   {
	

    var n, i, polyX, polyY, x1, y1, x2, y2;
	
	var poly = ds_list_create();
	for ( n = 0; n < array_length( polygon.vertices ); n ++ ) {
			
		ds_list_add( poly, polygon.vertices[n].x, polygon.vertices[n].y );
		
	}
   
    var inside = false;
    n = ds_list_size( poly ) div 2;
    for (i=0; i<n; i+=1)
    {
        polyX[i] = ds_list_find_value( poly, 2*i);
        polyY[i] = ds_list_find_value( poly, 2*i+1);
    }
    polyX[n] = polyX[0];
    polyY[n] = polyY[0];
    for (i=0; i<n; i+=1)
    {
        x1 = polyX[i];
        y1 = polyY[i];
        x2 = polyX[i+1];
        y2 = polyY[i+1];
 
        if ((y2 > y0) != (y1 > y0)) 
        {
            inside ^= (x0 < (x1-x2) * (y0-y2) / (y1-y2) + x2);
        }       
    }
	
	ds_list_destroy( poly );
	
    return inside;
      
	  //var n, i, x1, y1, x2, y2;
    //var inside	= false;
    //n			= array_length( polygon.vertices );
        
	//var array = [];
	//array_copy( array, 0, polygon.vertices, 0, n );
	//array_push( array, polygon.vertices[0] );
	
	//n = array_length( array ) - 1;
	
    //for ( i = 0; i < n; i += 1 ) {
			
    //    x1 = array[ i	].x;
    //    y1 = array[ i	].y;
    //    x2 = array[ i + 1].x;
    //    y2 = array[ i + 1].y;
     
    //    if (( y2 > y0 ) != ( y1 > y0 )) 
    //    {
    //        inside ^= ( x0 < ( x1 - x2 ) * ( y0 - y2 ) / ( y1 - y2 ) + x2 );
    //    }       
    //}
    //return inside;
}

/// @function point_list_sort( list, clockwise ) {
/// @param	list		{Ds_list}	A list containing instances/vectors/vertices to sort
/// @param	clockwise	{Bool}
function point_list_sort( list, clockwise = true ) {
	
	var prio		= ds_priority_create();
	var pointList	= ds_list_create();
	var closedList	= ds_list_create();
	
	var size = ds_list_size( list );
	var i;
	// Find leftmost point & add it as a starting point to pointList
	for ( i = 0; i < size; i ++ ) with ( list[| i] ) ds_priority_add( prio, self, x );
	
	
	var currentPoint, prevPoint;
	currentPoint = ds_priority_delete_min( prio );
	ds_priority_clear( prio );
	
	ds_list_add( closedList,	currentPoint );
	ds_list_add( pointList,		currentPoint );
	
	var check_angle = clockwise ? 270 : 90;
		
	do  {		
	
		ds_priority_clear( prio );

		// First point
		if ( ds_list_size( pointList ) == 1 ) {
				
			// Sort all other points by angle, find the point with the largest angle (counter)clockwise
			for ( i = 0; i < size; i ++ ) with ( list[| i] ) {
					
				// Only check "open" points
				if ( ds_list_find_index( closedList, self ) == -1 ) {
					var dir		= point_direction( currentPoint.x, currentPoint.y, x, y );
					var angle	= abs( angle_difference( dir, check_angle ));
					
					ds_priority_add( prio, self, angle );
				}
			}
			
			// Pick the point with the largest counterclockwise angle
			prevPoint		= currentPoint;
			currentPoint	= ds_priority_delete_max( prio );
			
			ds_list_add( pointList, currentPoint );
			ds_list_add( closedList, currentPoint );
			
		}
		
		// Rest of the points
		else {
			var prevDir = point_direction( prevPoint.x, prevPoint.y, currentPoint.x, currentPoint.y );
			
			// Sort all other points by angle, find the point with the largest angle counterclockwise
			for ( i = 0; i < size; i ++ ) with ( list[| i] ) {
				if ( self != currentPoint ) {

					var dir		= point_direction( currentPoint.x, currentPoint.y, x, y );
					var angle	= angle_difference( dir, prevDir );
						
					if		( clockwise && angle <= 0 )		ds_priority_add( prio, self, abs( angle ));
					else if ( !clockwise && angle >= 0 )	ds_priority_add( prio, self, abs( angle ));
					
						
				}
			}
		
			prevPoint		= currentPoint;
			currentPoint	= ds_priority_delete_min( prio );
			
			if ( ds_list_value_exists( closedList, currentPoint )) break;
			else {
				ds_list_add( pointList, currentPoint );
				ds_list_add( closedList, currentPoint );
			}
		
		}
	}
	// Exit when coming back to the first point
	until ( ds_list_size( pointList ) > 1 && currentPoint == pointList[| 0] || ds_list_size( pointList ) >= ds_list_size( list ));

	ds_list_destroy( closedList );
	ds_priority_destroy( prio );

	return pointList;
	
	

}


/// @function point_list_get_bounds( list ) {
/// @param	list		{Ds_list}	A list containing instances/vectors/vertices to sort
function point_list_get_bounds( list ) {
	
	var sort		= ds_list_create();
	
	var bounds = {};
	bounds.min_x = 0;
	bounds.max_x = 0;
	bounds.min_y = 0;
	bounds.max_y = 0;
	
	var size = ds_list_size( list );
	var i;
	
	for ( i = 0; i < size; i ++ ) with ( list[| i] ) ds_list_add( sort, x );
	ds_list_sort( sort, true );		bounds.min_x = sort[| 0 ];
	ds_list_sort( sort, false );	bounds.max_x = sort[| 0 ];
	ds_list_clear(sort );
	
	for ( i = 0; i < size; i ++ ) with ( list[| i] ) ds_list_add( sort, y );
	ds_list_sort( sort, true );		bounds.min_y = sort[| 0 ];
	ds_list_sort( sort, false );	bounds.max_y = sort[| 0 ];
	ds_list_clear(sort );
	
	ds_list_destroy( sort );
	
	return bounds;
	
}

// Checks if a given surface exists and creates + clears it if not
/// @function surface_check( surf, w, h, col ) {
/// @param surf		{Surface}	Surface to check
/// @param width	{Float}		Surface width
/// @param height	{Float}		Surface height
/// @param colour*	{Colour}	Clear colour
function surface_check( surf, w, h, col = c_black ) {

	if ( surface_exists( surf )) return surf;

	surf = surface_create( w, h );
	
	surface_set_target( surf );
		draw_clear_alpha( col, 1 );
	surface_reset_target();
	
	return surf;
	
}
	
	
/// @description tex_get(xtex, ytex, hornum, vernum, horsize, versize);
/// @param	xtex
/// @param  ytex
/// @param  hornum
/// @param  vernum
/// @param  horsize
/// @param  versize
function tex_get( xtex, ytex, hh, vv, hSize = 1, vSize = 1) {
	

	var tx1 = xtex / hh;
	var ty1 = ytex / vv;
	var tx2 = (xtex + hSize) / hh;
	var ty2 = (ytex + vSize) / vv;
	
	tx1 += 0.0001;
	tx1 -= 0.0001;
	ty2 += 0.0001;
	ty2 -= 0.0001;
	
	//return { x1 : tx1, y1 : ty1, x2 : tx2, y2 : ty2 };
	return [ tx1, ty1, tx2, ty2 ];

}

/// @function texture_get_tile_uv( texture, tile_x, tile_y, hor_tiles, ver_tiles, horsize, versize);
/// @param	texture
/// @param	tile_x
/// @param  tile_y
/// @param  hor_tiles
/// @param  ver_tiles
/// @param  horsize
/// @param  versize
function texture_get_tile_uv( texture, tile_x, tile_y, hor_tiles = 1, ver_tiles = 1, horsize = 1, versize = 1) {
	
	// Get texture page UVs
	var tex_uv = texture_get_uv_array( texture );
	
	// Get tile UVs
	var tx1 = tile_x / hor_tiles;
	var ty1 = tile_y / ver_tiles;
	var tx2 = ( tile_x + horsize ) / hor_tiles;
	var ty2 = ( tile_y + versize ) / ver_tiles;
	
	// Scale tile UVs to texture page UVs
	var w = tex_uv[2] - tex_uv[0];
	var h = tex_uv[3] - tex_uv[1];
	
	tx1 = lerp( tex_uv[0], tex_uv[2], tx1 );
	ty1 = lerp( tex_uv[1], tex_uv[3], ty1 );
	
	tx2 = lerp( tex_uv[0], tex_uv[2], tx2 );
	ty2 = lerp( tex_uv[1], tex_uv[3], ty2 );
	
	//tx1 += 0.0001;
	//tx1 -= 0.0001;
	//ty2 += 0.0001;
	//ty2 -= 0.0001;
	
	//return { x1 : tx1, y1 : ty1, x2 : tx2, y2 : ty2 };
	return [ tx1, ty1, tx2, ty2 ];

}

#region Gpu state

	global.__gpuState = gpu_get_state();

	
	/// @function gpu_state_get()
	function gpu_state_get() {
		ds_map_destroy( global.__gpuState );
		global.__gpuState = gpu_get_state();
	}
	gpu_state_get();
	
	/// @function gpu_state_reset();
	function gpu_state_reset() {
		gpu_set_state( global.__gpuState );
	}
	
	/// @function gpu_reset_blendmode()
	function gpu_reset_blendmode() {
		gpu_set_blendmode( bm_normal );
	}
	
	/// @function gpu_reset_cullmode()
	function gpu_reset_cullmode() {
		gpu_set_cullmode( global.__gpuState[? "cullmode" ] );
	}

#endregion


#region Json

	/// @function json_validate_parse( _string )
	/// @param		{String} string
	/// @return		{Any|Noone}
	function json_validate_parse( _string ) {
		
		var _return = noone;
		
		try {
		    _return = json_parse( _string );
		} 
		catch ( _error ) {
		    show_debug_message( "Couldn't parse JSON: " + _error.message );
			_return = noone;
		}
		
		return _return;
		
	}

#endregion


/// @function vec3_to_float( x, y, z ) {
function vec3_to_float( r, g, b ) {

	var _r = floor( r * 255.0 );
	var _g = floor( g * 255.0 * 255.0 );
	var _b = floor( b * ( 255.0 * 255.0 * 255.0 ));
	
	show_message( "r: " +string( r ));
	show_message( "g: " +string( g )); 
	show_message( "b: " +string( b )); 
	
	return ( _r + _g + _b );
}


/// @function float_to_vec3( float ) {
function float_to_vec3( f ) {
	
	var r = floor( f / ( 255.0 * 255.0 ) );
	var g = floor( ( f mod ( 255.0 * 255.0 ) ) / 255.0 );
	var b = ( f mod 255.0 );
	
	
    // now we have a vec3 with the 3 components in range [0..255]. Let's normalize it!
    return [ r, g, b ];
}


/// @function colour_to_float( col ) {
function colour_to_float( col ) {
	var r = colour_get_red(		col  ) / 255;
	var g = colour_get_green(	col  ) / 255;
	var b = colour_get_blue(	col  ) / 255;
	return vec3_to_float( r, g, b );
}

/// @function float_to_colour( float ) {
function float_to_colour( float ) {
	var c = float_to_vec3( float );
	return make_colour( c[0], c[1], c[2] );
}

/// @function colour_to_rgb( col, normalize );
function colour_to_rgb( col, norm = false ) {
	
	var n = norm ? 255.0 : 1.0;
	
	return [ colour_get_red( col ) / n,  colour_get_green( col ) / n, 	colour_get_blue( col ) / n ]; 	
	
}

/// @function colour_to_array( col ) {
function colour_to_array( col, alpha = 1.0 ) {
	var r = colour_get_red(		col  ) / 255;
	var g = colour_get_green(	col  ) / 255;
	var b = colour_get_blue(	col  ) / 255;
	return [ r, g, b, alpha ];
}

/// @function get_value( variable, choose_type )
/// @param {Real|Array<Any}		variable
/// @param {Function}			choose_type
function get_value( variable, choose_type = random_range ) {
	
	if ( is_real( variable )) return variable;
	else if ( is_array( variable )) {
		
		if ( array_length( variable ) == 0 ) return 0;
		if ( array_length( variable ) == 1 ) return variable[0];
		
		switch ( choose_type ) {
			
			case random_range:
				return random_range( variable[0], variable[1] );
			break;
			
			case irandom_range:
				return irandom_range( variable[0], variable[1] );
			break;
			
			case choose:
				var i = irandom( array_length( variable ) - 1 );
				return variable[i];
			break;
			
			
		}
		
	}
	
	return variable;
	
}