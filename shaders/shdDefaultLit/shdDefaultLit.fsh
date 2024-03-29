//
// Simple passthrough fragment shader
//

#define pi 3.14159265359

varying vec2	v_vTexCoord;
varying vec4	v_vVertexColour;
varying vec3	v_vNormal;
varying vec3	v_vPosition;
varying vec3	v_vLocalNormal;
varying vec3	v_vLocalPosition;

varying vec3	v_vFogValues;				// RGB, A = fog value
varying vec3	v_vCamPosition;
varying vec4	v_vShadowCoord[3];
varying float	v_vDepthValue;

// Shadows
uniform float		uEnableShadows;				// Toggle shadows on/off
uniform sampler2D	uShadowMap0;				// Shadow depth texture 0
uniform sampler2D	uShadowMap1;				// Shadow depth texture 1
uniform sampler2D	uShadowMap2;				// Shadow depth texture 2
uniform float		uShadowMapSize[3];			// Size of shadow texture
uniform vec3		uShadowClipValues[3];		// Near & far clipping planes of the cameras
const float			cDepthBias		= 0.002;
const float			cNormalBias		= 0.002;
const int			cMaxCascades	= 3;

// Lighting
uniform float	uEnableLighting;
uniform vec4	uAmbientColour;
uniform vec4	uLightColour;
uniform vec3	uLightDirection;

// Material
uniform float		uTexCoord[4];



float inverse_pow( float a, float b ) {
	return 1.0 - pow( 1.0 - a, b );
}

// texture coordinate scale
vec2 get_texture_coord( vec2 pos, float texCoord[4] ) {
	
	pos.x = mod( pos.x, 1.0 );
	pos.y = mod( pos.y, 1.0 );
	
	float U0 = texCoord[0];
	float V0 = texCoord[1];
	float U1 = texCoord[2];
	float V1 = texCoord[3];
	
	float U = U0 + ( U1 - U0 ) * pos.x;
	float V = V0 + ( V1 - V0 ) * pos.y;
	
    return vec2( U, V );
}

// Pack depth
vec3 pack_depth( float f ) {
    return vec3( floor( f * 255.0 ) / 255.0, fract( f * 255.0 ), fract( f * 255.0 * 255.0 ) );
}

// Unpack depth
float get_depth( vec3 v ) {
    float val = ( v.r ) + ( v.g / 255.0 ) + ( v.b / ( 255.0 * 255.0 ));
    return ( 1.0 - val );
}

// Smooth shadows
float get_smooth_shadow( sampler2D shadowMap, int plane, vec2 coord, float currentDepth, float bias ) {
	
	float pixel = 1.0 / uShadowMapSize[ plane ];

	int xx, yy;
		
	float shadow	= 0.0;
	float depth		= 0.0;
	float zDepth	= currentDepth;
	vec2 _coord;
		
	for ( xx = -1; xx <= 1; xx ++ ) {
		for ( yy = -1; yy <= 1; yy ++ ) {
				
			_coord.x = float( xx ) * pixel;
			_coord.y = float( yy ) * pixel;
				
			depth = get_depth( texture2D( shadowMap, coord + _coord ).rgb );
			shadow += ( zDepth - bias < depth ) ? 0.0 : 1.0;
		}
	}
		
	shadow /= 9.0;
		
	return shadow;
}


// Get lighting
vec4 get_lighting( vec3 worldPos, vec3 normal ) {
	
	vec4 lightColour	= uAmbientColour;
	vec3 camVector		= normalize( v_vCamPosition - worldPos );
	
	// Directional lighting
	normal *= !gl_FrontFacing ? -1.0 : 1.0;
	
	float lightValue	= dot( normal, -uLightDirection );
	lightValue			= ( lightValue + 1.0 ) * 0.5; // Half-lambertian shading
	
	lightValue = clamp( lightValue, 0.0, 1.0 );
	
	lightColour			= mix( uAmbientColour, uLightColour, lightValue );
	
	return lightColour;
	
}



void main()
{
	
	// Base colour
	vec4 texColour	= texture2D( gm_BaseTexture, get_texture_coord( v_vTexCoord, uTexCoord ));
	vec4 baseColour	= texColour * v_vVertexColour;
	
	// Output colour
	vec4 outColour = baseColour;
	
	
	// Get lighting
	vec4 lightColour = get_lighting( v_vPosition, v_vNormal );
	

	// Shadows 
	int plane = -1;
	int p;
	vec2 coord;
	
	// Choose closest shadow cascade
	for ( p = 0; p < cMaxCascades; p += 1 ) {
		
		// Get coordinate in shadow map space
		coord = v_vShadowCoord[p].xy / v_vShadowCoord[p].w * vec2( 0.5, 0.5 ) + 0.5;
		
		// Check that the position is inside the cascade  -- TODO: Change this to use DEPTH instead of XY
	    if ( coord.x >= 0.0 && coord.y >= 0.0 && coord.x <= 1.0 && coord.y <= 1.0 ) {
			
			plane = p;
			break;
		}
	}
	
	// No available shadow maps
	if ( plane == -1 || uEnableShadows == 0.0 ) {
		
		// Multiply by light
		if ( uEnableLighting == 1.0 ) outColour *= lightColour;
		
	}
	else {
		
		float shadow		= 0.0;
		float depthBias		= 0.002;
		float normalBias	= 0.002;
		
		float linearDepth		= ( v_vShadowCoord[plane].z / v_vShadowCoord[plane].w );

		if ( plane == 0 ) depthBias = 0.0005;
		if ( plane == 1 ) depthBias = 0.0002;
		if ( plane == 2 ) depthBias = 0.01;
		
		float bias = max( depthBias * ( 1.0 - dot( v_vNormal, uLightDirection )), depthBias );
		
		if ( plane == 0 )		shadow = get_smooth_shadow( uShadowMap0, plane, coord, linearDepth, bias );
		else if ( plane == 1 )	shadow = get_smooth_shadow( uShadowMap1, plane, coord, linearDepth, bias );
		else if ( plane == 2 )	shadow = get_smooth_shadow( uShadowMap2, plane, coord, linearDepth, bias );
		
		// Only apply shadows on faces facing the light
		float normal_factor = max( 0.0, dot( v_vNormal, -uLightDirection ));
		normal_factor = smoothstep( 0.1, 0.2, normal_factor );
		shadow *= normal_factor;
		
		// Multiply by light
		if ( uEnableLighting == 1.0 ) {
			
			// Fade to ambient colour for shadows
			lightColour = mix( lightColour, uAmbientColour, smoothstep( 0.1, 1.0, shadow ));
			
			outColour *= lightColour;
		}
		
	}
	
	gl_FragData[0] = outColour;
	
	// Visualize world position
	//float R = smoothstep( 0.9, 1.0, abs( 0.5 - mod( v_vPosition.x * 0.1, 1.0 )) * 2.0 );
	//float G = smoothstep( 0.9, 1.0, abs( 0.5 - mod( v_vPosition.y * 0.1, 1.0 )) * 2.0 );
	//float B = smoothstep( 0.9, 1.0, abs( 0.5 - mod( v_vPosition.z * 0.1, 1.0 )) * 2.0 );
	//gl_FragData[0] = vec4( R, G, B, 1.0 );
	
}
