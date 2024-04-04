//
// Screen space volumetric fog shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexCoord;
varying vec4 v_vColour;
varying vec3 v_vCamPosition;
varying vec3 v_vViewRay;

uniform vec3	uCamPosition;			// Camera position in world space
uniform vec3	uFrustumPoints[4];		// Frustum corner positions in world space

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
	int n = 0;
	n += int( in_TextureCoord.x );
	n += int( in_TextureCoord.y ) * 2;
	vec3 frustumPoint	= uFrustumPoints[n];			// Corner position in world space
	v_vViewRay			= normalize( frustumPoint - uCamPosition );
	
	v_vTexCoord		= in_TextureCoord;
	v_vColour		= in_Colour;
	v_vCamPosition	= uCamPosition;

}
