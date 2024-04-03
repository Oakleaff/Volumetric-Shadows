//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;             // (x,y,z)
attribute vec3 in_Normal;				// (x,y,z)    
attribute vec4 in_Colour;               // (r,g,b,a)
attribute vec2 in_TextureCoord;         // (u,v)

varying vec2	v_vTexCoord;
varying vec3	v_vNormal;
varying vec3	v_vPosition;
varying vec4	v_vVertexColour;				
varying vec3	v_vCamPosition;
varying vec4	v_vShadowCoord[3];
varying vec3	v_vLocalNormal;
varying vec3	v_vLocalPosition;

uniform vec4	uColour;



uniform mat4	uDepthMatrix[3];	// VP matrix of the shadow projection cameras



void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	vec4 worldPos = gm_Matrices[MATRIX_WORLD] * object_space_pos;
	
	// Extract rotation matrix of the world matrix
	mat4 in_rotation		= gm_Matrices[MATRIX_WORLD];
	mat3 rotationMatrix		= mat3( in_rotation );
	
	// Calculate rotated vertex normals
	v_vNormal	= normalize( rotationMatrix * in_Normal );
	
	// Light colour from vertex
	v_vVertexColour = in_Colour * uColour;
	
	// Position in shadow map spaces
    v_vShadowCoord[0]	= uDepthMatrix[0] * worldPos;
	v_vShadowCoord[1]	= uDepthMatrix[1] * worldPos;
	v_vShadowCoord[2]	= uDepthMatrix[2] * worldPos;
	
    v_vTexCoord = in_TextureCoord;
	v_vPosition = worldPos.xyz;
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	

	v_vLocalNormal		= in_Normal;
	v_vLocalPosition	= in_Position;
	

}
