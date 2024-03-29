//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexCoord;
varying vec4 v_vColour;
varying vec3 v_vPosition;

uniform vec4 uColour;


void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour	= in_Colour * uColour;
    v_vTexCoord = in_TextureCoord;
	
	v_vPosition = ( gm_Matrices[MATRIX_WORLD] * object_space_pos ).xyz;
	
}
