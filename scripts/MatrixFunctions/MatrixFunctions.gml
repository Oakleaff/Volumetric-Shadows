/// Matrix function library

include( "MatrixFunctions" );
require( "Vectors" );
require( "Quaternions" );

// https://upsetbabygames.com/docs/UBG%203D2D%20Interaction/
/// @function	matrix_invert
/// @desc		Calculates the inverse of the specified matrix or undefined if it cannot be calculated.
///	@param		matrix	matrix	matrix to find inverse of
///	@param		fast		use fast or not
///	@returns	{Array<Real>}
function matrix_invert( matrix, fast = true ) {
	
	if ( fast ) return matrix_invert_fast( matrix );
 
	// Determine if it is a proper matrix:
	if (!is_array( matrix ))
	    show_error("Expected type [matrix]!", true);
    
	if (array_length( matrix ) != 16)
	    show_error("Expected type [matrix]!", true);
    
	var _inverse = 0,
	    _determinant = get_matrix_determinant(matrix);
                 
	if (debug_mode && _determinant == 0) 
	{
	    show_error("Cannot calculate inverse matrix. Determinant = 0!", false);
		return undefined;
	}
    
	var _a11 = matrix[0],
	    _a12 = matrix[1],
	    _a13 = matrix[2],
	    _a14 = matrix[3],
    
	    _a21 = matrix[4],
	    _a22 = matrix[5],
	    _a23 = matrix[6],
	    _a24 = matrix[7],
    
	    _a31 = matrix[8],
	    _a32 = matrix[9],
	    _a33 = matrix[10],
	    _a34 = matrix[11],
    
	    _a41 = matrix[12],
	    _a42 = matrix[13],
	    _a43 = matrix[14],
	    _a44 = matrix[15];
    
	_inverse[15] = 0; // Allocate space

	// Calculate second base matrix:
	    // [1, 1]
	_inverse[0] = _a22 * _a33 * _a44 +
	               _a23 * _a34 * _a42 +
	               _a24 * _a32 * _a43 -
	               _a22 * _a34 * _a43 -
	               _a23 * _a32 * _a44 -
	               _a24 * _a33 * _a42;
               
	    //[1, 2]
	_inverse[1] = _a12 * _a34 * _a43 +
	               _a13 * _a32 * _a44 +
	               _a14 * _a33 * _a42 -
	               _a12 * _a33 * _a44 -
	               _a13 * _a34 * _a42 -
	               _a14 * _a32 * _a43;
        
	    //[1, 3]       
	_inverse[2] = _a12 * _a23 * _a44 +
	               _a13 * _a24 * _a42 +
	               _a14 * _a22 * _a43 -
	               _a12 * _a24 * _a43 -
	               _a13 * _a22 * _a44 -
	               _a14 * _a23 * _a42;
    
	    //[1, 4]           
	_inverse[3] =  _a12 * _a24 * _a33 +
	                _a13 * _a22 * _a34 +
	                _a14 * _a23 * _a32 -
	                _a12 * _a23 * _a34 -
	                _a13 * _a24 * _a32 -
	                _a14 * _a22 * _a33;
               
	   //[2, 1] 
	_inverse[4] =  _a21 * _a34 * _a43 +
	                _a23 * _a31 * _a44 +
	                _a24 * _a33 * _a41 -
	                _a21 * _a33 * _a44 -
	                _a23 * _a34 * _a41 -
	                _a24 * _a31 * _a43;
                
	    //[2, 2]
	_inverse[5] =  _a11 * _a33 * _a44 +
	                _a13 * _a34 * _a41 +
	                _a14 * _a31 * _a43 -
	                _a11 * _a34 * _a43 -
	                _a13 * _a31 * _a44 -
	                _a14 * _a33 * _a41;
                
	    //[2, 3]
	_inverse[6] =  _a11 * _a24 * _a43 +
	                _a13 * _a21 * _a44 +
	                _a14 * _a23 * _a41 -
	                _a11 * _a23 * _a44 -
	                _a13 * _a24 * _a41 -
	                _a14 * _a21 * _a43;
                
	    //[2, 4]
	_inverse[7] =  _a11 * _a23 * _a34 +
	                _a13 * _a24 * _a31 +
	                _a14 * _a21 * _a33 -
	                _a11 * _a24 * _a33 -
	                _a13 * _a21 * _a34 -
	                _a14 * _a23 * _a31;
                
	    //[3, 1]
	_inverse[8] =  _a21 * _a32 * _a44 +
	                _a22 * _a34 * _a41 +
	                _a24 * _a31 * _a42 -
	                _a21 * _a34 * _a42 -
	                _a22 * _a31 * _a44 -
	                _a24 * _a32 * _a41;
                
	    //[3, 2]
	_inverse[9] =  _a11 * _a34 * _a42 +
	                _a12 * _a31 * _a44 +
	                _a14 * _a32 * _a41 -
	                _a11 * _a32 * _a44 -
	                _a12 * _a34 * _a41 -
	                _a14 * _a31 * _a42;
                
	    //[3, 3]
	_inverse[10] = _a11 * _a22 * _a44 +
	                _a12 * _a24 * _a41 +
	                _a14 * _a21 * _a42 -
	                _a11 * _a24 * _a42 -
	                _a12 * _a21 * _a44 -
	                _a14 * _a22 * _a41;
                
	    //[3, 4]
	_inverse[11] = _a11 * _a24 * _a32 +
	                _a12 * _a21 * _a34 +
	                _a14 * _a22 * _a31 -
	                _a11 * _a22 * _a34 -
	                _a12 * _a24 * _a31 -
	                _a14 * _a21 * _a32;
                
	    //[4, 1]
	_inverse[12] = _a21 * _a33 * _a42 +
	                _a22 * _a31 * _a43 +
	                _a23 * _a32 * _a41 -
	                _a21 * _a32 * _a43 -
	                _a22 * _a33 * _a41 -
	                _a23 * _a31 * _a42;
                
	    //[4, 2]
	_inverse[13] = _a11 * _a32 * _a43 +
	                _a12 * _a33 * _a41 +
	                _a13 * _a31 * _a42 -
	                _a11 * _a33 * _a42 -
	                _a12 * _a31 * _a43 -
	                _a13 * _a32 * _a41;
                
	    //[4, 3]
	_inverse[14] = _a11 * _a23 * _a42 +
	                _a12 * _a21 * _a43 +
	                _a13 * _a22 * _a41 -
	                _a11 * _a22 * _a43 -
	                _a12 * _a23 * _a41 -
	                _a13 * _a21 * _a42;
                
	    //[4, 4]
	_inverse[15] = _a11 * _a22 * _a33 +
	                _a12 * _a23 * _a31 +
	                _a13 * _a21 * _a32 -
	                _a11 * _a23 * _a32 -
	                _a12 * _a21 * _a33 -
	                _a13 * _a22 * _a31;
                
	// Multiply by determinant:
	_determinant = 1 / _determinant;
    
    
	for (var i = 0; i < 16; ++i)
	    _inverse[i] *= _determinant;
                
	return _inverse;



}


/// @func matrix_invert_fast(M, targetM*)
function matrix_invert_fast(M, I = array_create(16)) 
{
	//Returns the inverse of a 4x4 matrix. Assumes indices 3, 7 and 11 are 0, and index 15 is 1
	//With this assumption a lot of factors cancel out
	var m0 = M[0], m1 = M[1], m2 = M[2], m4 = M[4], m5 = M[5], m6 = M[6], m8 = M[8], m9 = M[9], m10 = M[10], m12 = M[12], m13 = M[13], m14 = M[14];
	var i0  =   m5 * m10 -  m9 * m6;
	var i4  =   m8 * m6  -  m4 * m10;
	var i8  =   m4 * m9  -  m8 * m5;
	var det =   dot_product_3d(m0, m1, m2, i0, i4, i8);
	if (det == 0)
	{
		show_debug_message("Error in function matrix_invert_fast: The determinant is zero.");
		return M;
	}
	var invDet = 1 / det;
	I[@ 0]  =   invDet * i0;
	I[@ 1]  =   invDet * (m9 * m2  - m1 * m10);
	I[@ 2]  =   invDet * (m1 * m6  - m5 * m2);
	I[@ 3]  =   0;
	I[@ 4]  =   invDet * i4;
	I[@ 5]  =   invDet * (m0 * m10 - m8 * m2);
	I[@ 6]  =   invDet * (m4 * m2  - m0 * m6);
	I[@ 7]  =   0;
	I[@ 8]  =   invDet * i8;
	I[@ 9]  =   invDet * (m8 * m1  - m0 * m9);
	I[@ 10] =   invDet * (m0 * m5  - m4 * m1);
	I[@ 11] =   0;
	I[@ 12] = - dot_product_3d(m12, m13, m14, I[0], I[4], I[8]);
	I[@ 13] = - dot_product_3d(m12, m13, m14, I[1], I[5], I[9]);
	I[@ 14] = - dot_product_3d(m12, m13, m14, I[2], I[6], I[10]);
	I[@ 15] =   dot_product_3d(m8,  m9,  m10, I[2], I[6], I[10]);
	return I;
}

// https://upsetbabygames.com/docs/UBG%203D2D%20Interaction/
/// @function	get_matrix_determinant
/// @desc		Calculates the determinant of a matrix.
///	@param		{matrix}	matrix	matrix to process
///	@returns	{real
function get_matrix_determinant( matrix ) {
	

	if (!is_array( matrix ))
	    show_error("(matrix): Expected type [matrix]!", true);
    
	if (array_length( matrix ) != 16)
	    show_error("(matrix): Expected type [matrix]!", true);
 
	var _determinant = 0; 

	var _a11 = matrix[0],
	    _a12 = matrix[1],
	    _a13 = matrix[2],
	    _a14 = matrix[3],
    
	    _a21 = matrix[4],
	    _a22 = matrix[5],
	    _a23 = matrix[6],
	    _a24 = matrix[7],
    
	    _a31 = matrix[8],
	    _a32 = matrix[9],
	    _a33 = matrix[10],
	    _a34 = matrix[11],
    
	    _a41 = matrix[12],
	    _a42 = matrix[13],
	    _a43 = matrix[14],
	    _a44 = matrix[15];

	_determinant = _a11 * _a22 * _a33 * _a44 +
	                _a11 * _a23 * _a34 * _a42 +
	                _a11 * _a24 * _a32 * _a43 +
                
	                _a12 * _a21 * _a34 * _a43 +
	                _a12 * _a23 * _a31 * _a44 +
	                _a12 * _a24 * _a33 * _a41 +
                
	                _a13 * _a21 * _a32 * _a44 +
	                _a13 * _a22 * _a34 * _a41 +
	                _a13 * _a24 * _a31 * _a42 +
                
	                _a14 * _a21 * _a33 * _a42 +
	                _a14 * _a22 * _a31 * _a43 +
	                _a14 * _a23 * _a32 * _a41;
                
	    // Part two:
	_determinant += -_a11 * _a22 * _a34 * _a43
	                 -_a11 * _a23 * _a32 * _a44
	                 -_a11 * _a24 * _a33 * _a42
                 
	                 -_a12 * _a21 * _a33 * _a44
	                 -_a12 * _a23 * _a34 * _a41
	                 -_a12 * _a24 * _a31 * _a43
                 
	                 -_a13 * _a21 * _a34 * _a42
	                 -_a13 * _a22 * _a31 * _a44
	                 -_a13 * _a24 * _a32 * _a41
                 
	                 -_a14 * _a21 * _a32 * _a43
	                 -_a14 * _a22 * _a33 * _a41
	                 -_a14 * _a23 * _a31 * _a42;
                 
	return _determinant;



}

/// @function matrix_convert_2d( matrix )
// Convert a 1d 16-component matrix to a 2d 4x4 matrix
function matrix_convert_2d( mat) {

	var matrix;

	for ( var i = 0; i < 16; i ++ ) {
		var xx = i mod 4;
		var yy = floor( i / 4 );
	
		matrix[xx][yy] = mat[ i ];
	}

	return ( matrix );
}

// inverts a 3x3 matrix
/// @function invert_mat3( matrix )
/// @param matrix
function invert_mat3( A ) {
	
  // determinant(A)
  var invDeterminant = 1.0 / 
           (-A[2] * A[4] * A[6] + 
             A[1] * A[5] * A[6] + 
             A[2] * A[3] * A[7] - 
	     A[0] * A[5] * A[7] - 
	     A[1] * A[3] * A[8] + 
	     A[0] * A[4] * A[8]);

	var inv;
	inv[0] = invDeterminant * (-A[5] * A[7] + A[4] * A[8]);
	inv[1] = invDeterminant * (A[2] * A[7] - A[1] * A[8]);
	inv[2] = invDeterminant * (-A[2] * A[4] + A[1] * A[5]);
	inv[3] = invDeterminant * (A[5] * A[6] - A[3] * A[8]);
	inv[4] = invDeterminant * (-A[2] * A[6] + A[0] * A[8]);
	inv[5] = invDeterminant * (A[2] * A[3] - A[0] * A[5]);
	inv[6] = invDeterminant * (-A[4] * A[6] + A[3] * A[7]);
	inv[7] = invDeterminant * (A[1] * A[6] - A[0] * A[7]);
	inv[8] = invDeterminant * (-A[1] * A[3] + A[0] * A[4]);
	
	return inv;
}

// Transforms the quaternion to the corresponding rotation matrix.
// Quaternion is assumed to be a unit quaternion.
// R is a 3x3 orthogonal matrix and will be returned in row-major order.
/// @function quaternion_to_mat3( quat ) {
function quaternion_to_mat3( q ) {
	
	var R = [];
	
	R[0] = 1 - 2 * q.y * q.y - 2 * q.z * q.z;	R[1] = 2 * q.x * q.y - 2 * q.w * q.z;		R[2] = 2 * q.x * q.z + 2 * q.w * q.y;
	R[3] = 2 * q.x * q.y + 2 * q.w * q.z;		R[4] = 1 - 2 * q.x * q.x - 2 * q.z * q.z;	R[5] = 2 * q.y * q.z - 2 * q.w * q.x;
	R[6] = 2 * q.x * q.z - 2 * q.w * q.y;		R[7] = 2 * q.y * q.z + 2 * q.w * q.x;		R[8] = 1 - 2 * q.x * q.x - 2 * q.y * q.y;
	
	return R;
  
}

/// @function mat4_to_mat3( mat4 ) {
function mat4_to_mat3( mat4 ) {
	
	var mat3 = [];
	
	// 3x3 portion of the rotation matrix
	/* Rotation matrix
	[0][1][2][3]
	[4][5][6][7]
	[8][9][10][11]
	[12][13][14][15]
	*/
		
	mat3[0] = mat4[0];
	mat3[1] = mat4[4];
	mat3[2] = mat4[8];

	mat3[3] = mat4[1];
	mat3[4] = mat4[5];
	mat3[5] = mat4[9];
			
	mat3[6] = mat4[2];
	mat3[7] = mat4[6];
	mat3[8] = mat4[10];
	
	return mat3;
	
}

// @function mat3_to_mat4( mat3 ) {
function mat3_to_mat4( mat3 ) {
	
	var mat4 = [];
	
	// 3x3 portion of the rotation matrix
	/* Rotation matrix
	[0][1][2][3]
	[4][5][6][7]
	[8][9][10][11]
	[12][13][14][15]
	*/
		
	mat4[0] = mat3[0];
	mat4[1] = mat3[1];
	mat4[2] = mat3[2];
	mat4[3] = 0; 
	mat4[4] = mat3[3];
	mat4[5] = mat3[4];
	mat4[6] = mat3[5];
	mat4[7] = 0; 	 
	mat4[8] = mat3[6];
	mat4[9] = mat3[7];
	mat4[10] = mat3[8];
	mat4[11] = 0; 
	
	mat4[12] = 0; 
	mat4[13] = 0; 
	mat4[14] = 0; 
	mat4[15] = 1; 
	
	return mat4;
	
}

/// @function mat_multiply( A, B );
/// @param A	{mat}
/// @param B	{mat}
function mat_multiply( A, B ) {
	
	var numA = array_length( A );
	var numB = array_length( B );
	var A4, B4;
	if ( numA < 16 )	A4 = mat3_to_mat4( A );
	else				A4 = A;
	
	if ( numB < 16 )	B4 = mat3_to_mat4( B );
	else				B4 = B;
	
	
	var mat = matrix_multiply( A4, B4 );
	
	return ( numA == 9 ? mat4_to_mat3( mat ) : mat );
	
}

/// @function matrix_build_transform( position, rotation )
/// @param {Struct.Vector3}				position 
/// @param {Struxt.Quaternion|Matrix}	rotation 
function matrix_build_transform( _pos = new Vector3(), _rot = undefined ) {
	
	var _matrix;
	static rot0 = new Quaternion();
	
	_rot = _rot ?? rot0;
	
	if ( !is_array( _rot )) {
		_matrix = quaternion_to_matrix( _rot );
	}
	else {
		_matrix = array_create( 16 );
		//array_copy( _matrix, 0, _rot, 0, 12 );
		
		_matrix[  0	 ]	= _rot[  0	];
		_matrix[  1	 ]	= _rot[  1	];
		_matrix[  2	 ]	= _rot[  2	];
		
		_matrix[  4	 ]	= _rot[  4	];
		_matrix[  5	 ]	= _rot[  5	];
		_matrix[  6	 ]	= _rot[  6	];
		
		_matrix[  8	 ]	= _rot[  8	];
		_matrix[  9	 ]	= _rot[  9	];
		_matrix[  10 ]	= _rot[  10	];
		
		_matrix[  15 ]	= 1.0;
		
	}
	
	_matrix[ 12 ] = _pos.x;
	_matrix[ 13 ] = _pos.y;
	_matrix[ 14 ] = _pos.z;
	
	return _matrix;
}

/// @function matrix_build_lookat_vectors( from, to, up ) {
function matrix_build_lookat_vectors( from, to, up ) {

	return matrix_build_lookat( from.x, from.y, from.z, to.x, to.y, to.z, up.x, up.y, up.z );

}


/// @function matrix_transpose( matrix )
/// @param matrix
function matrix_transpose( matrix ) {
	
	var mat = [];
	var len = array_length( matrix );
	
	
	
	// 0  1  2  
	// 3  4  5  
	// 6  7  8 
	if ( len == 9 ) {
		
		mat[0] = matrix[0];	
		mat[1] = matrix[3];	
		mat[2] = matrix[6];	
		mat[3] = matrix[1];	
		mat[4] = matrix[4];	
		mat[5] = matrix[7];	
		mat[6] = matrix[2];	
		mat[7] = matrix[5];	
		mat[8] = matrix[8];	
	
		return mat;
	}
		
	// 0  1  2  3
	// 4  5  6  7
	// 8  9  10 11
	// 12 13 14 15
	if ( len == 16 ) {
		
		mat[0]	= matrix[0];	
		mat[1]	= matrix[4];	
		mat[2]	= matrix[8];	
		mat[3]	= matrix[12];	
		mat[4]	= matrix[1];	
		mat[5]	= matrix[5];	
		mat[6]	= matrix[9];	
		mat[7]	= matrix[13];	
		mat[8]	= matrix[2];	
		mat[9]	= matrix[6];	
		mat[10] = matrix[10];	
		mat[11] = matrix[14];	
		mat[12] = matrix[3];	
		mat[13] = matrix[7];	
		mat[14] = matrix[11];	
		mat[15] = matrix[15];	
	
		return mat;
	}
	
	return noone;
	
}
	
	
	
/// @function matrix_lerp( a, b, t, targ )
/// @param {Array<Real>}	a
/// @param {Array<Real>}	b
/// @param {Real}			t
/// @param {Array<Real>}	target
function matrix_lerp( a, b, t, targ = noone ) {
	
	var _len = min( array_length( a ), array_length( b ));
	
	if ( targ == noone ) targ = array_create( _len );
	
	for ( var i = 0; i < _len; i ++ ) {
		
		if ( a[i] == b[i] ) {
			targ[i] = a[i];	
			continue;
		}
		
		targ[i] = lerp( a[i], b[i], t );
	}
	return targ;
}