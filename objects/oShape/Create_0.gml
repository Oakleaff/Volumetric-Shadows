/// @description 

asset		= Assets.cube;
castShadows = true;

x = random_range( -30, 30 ) * METER;
y = random_range( -30, 30 ) * METER;
z = random_range( 0, 10 ) * METER;

position	= new Vector3( x, y, z );
rotation	= random_quaternion();
scale		= new Vector3( random_range( 5, 20 ), random_range( 5, 20 ), random_range( 5, 20 ));

positionMatrix	= matrix_build( position.x, position.y, position.z, 0, 0, 0, 1, 1, 1 );
rotationMatrix	= rotation.Matrix();
scaleMatrix		= matrix_build( 0, 0, 0, 0, 0, 0, scale.x, scale.y, scale.z );

transformMatrix = matrix_multiply( rotationMatrix, positionMatrix );
transformMatrix = matrix_multiply( scaleMatrix, transformMatrix );


/// @function render() {
function render() {

	matrix_transform( transformMatrix );
	vertex_submit( asset.mesh, pr_trianglelist, Level.texture );	

}