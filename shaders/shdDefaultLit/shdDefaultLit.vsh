//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2	v_vTexCoord;
varying vec3	v_vNormal;
varying vec3	v_vPosition;
varying vec4	v_vVertexColour;
varying vec3	v_vFogValues;				
varying vec3	v_vCamPosition;
varying vec4	v_vShadowCoord[3];
varying float	v_vDepthValue;
varying vec3	v_vLocalNormal;
varying vec3	v_vLocalPosition;

uniform vec4	uColour;
uniform float	uVertexOffset;
uniform float	uLitValue;

uniform float	uCamNear;
uniform float	uCamFar;

uniform float	uFogValues[12];		// Center x, center y, center z, enable distance fog, start, end, enable bottom fog, start, end, enable ceiling fog, start, end
uniform mat4	uDepthMatrix[3];	// VP matrix of the shadow projection cameras


/// Alpha dither
varying float	v_vAlphaValue;
uniform vec3	uCamPosition;
uniform vec3	uCamTarget;
float get_alpha_value( vec3 world_pos ) {
	
	float _value = 1.0;

	if ( world_pos.z > uCamTarget.z + 1.0 && distance( uCamPosition.xy, uCamTarget.xy ) > distance( uCamPosition.xy, world_pos.xy )) {
		
		vec3 _vec_to_cam_target = normalize( uCamTarget - world_pos );
		vec3 _vec_to_cam		= normalize( uCamPosition - world_pos );
		float _dot				= dot( _vec_to_cam, _vec_to_cam_target );
		
		_value = 1.0 - abs( _dot );
		_value = smoothstep( 0.2, 0.4, _value );
		_value = max( 0.10, _value );
		
	}
	
	return _value;
}


vec3 get_fog( vec3 pos ) {
	
	// Center fog
	vec3 center_pos = vec3( uFogValues[0], uFogValues[1], uFogValues[2] );
	float _enable	= uFogValues[3];
	float _start	= uFogValues[4];
	float _end		= uFogValues[5];
	float _val0 = ( distance( pos, center_pos ) - _start ) / ( _end - _start );
	_val0 = clamp( _val0, 0.0, 1.0 ) * _enable;
	
	// Bottom fog
	_enable		= uFogValues[6];
	_start		= uFogValues[7];
	_end		= uFogValues[8];
	float _val1 = ( pos.z - _start ) / ( _end - _start );
	_val1 = clamp( _val1, 0.0, 1.0 ) * _enable;
	
	// Ceiling fog
	_enable		= uFogValues[9];
	_start		= uFogValues[10];
	_end		= uFogValues[11];
	float _val2 = ( pos.z - _start ) / ( _end - _start );
	_val2 = clamp( _val2, 0.0, 1.0 ) * _enable;
	
	
	return vec3( _val0, _val1, _val2 );
}

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
	
	// Vertex offset
	object_space_pos.xyz += in_Normal * uVertexOffset;
	
	// Position in shadow map spaces
    v_vShadowCoord[0]	= uDepthMatrix[0] * worldPos;
	v_vShadowCoord[1]	= uDepthMatrix[1] * worldPos;
	v_vShadowCoord[2]	= uDepthMatrix[2] * worldPos;
	
	// Fog values ( center, bottom, rop )
	v_vFogValues = get_fog( worldPos.xyz );
	
    v_vTexCoord = in_TextureCoord;
	v_vPosition = worldPos.xyz;
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	
	
	//v_vCamVector = normalize( uCamPosition - worldPos );
	v_vCamPosition = uCamPosition;
	
	//// Dithering
	//v_vAlphaValue = get_alpha_value( worldPos.xyz );
	
	// Camera depth
	float zz		= ( gm_Matrices[MATRIX_WORLD_VIEW] * object_space_pos ).z;
	v_vDepthValue	= 1.0 - ( zz - uCamNear ) / ( uCamFar - uCamNear );
   
	v_vLocalNormal		= in_Normal;
	v_vLocalPosition	= in_Position;

}
