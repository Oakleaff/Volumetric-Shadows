//
// Simple passthrough fragment shader
//
varying vec2 v_vTexCoord;
varying vec4 v_vColour;
varying vec3 v_vCamPosition;
varying vec3 v_vViewRay;

uniform float	uCamNear;
uniform float	uCamFar;

uniform float uTime;

uniform float		uTexCoord[4];
uniform sampler2D	uNoiseTexture;
//uniform vec4		uColour;

// Lighting
uniform vec3	uLightDirection;
uniform vec4	uLightColour;

// Shadows
uniform float		uEnableShadows;				// Toggle shadows on/off
uniform mat4		uDepthMatrix[3];			// VP matrix of the shadow projection cameras
uniform sampler2D	uShadowMap0;				// Shadow depth texture 0
uniform sampler2D	uShadowMap1;				// Shadow depth texture 1
uniform sampler2D	uShadowMap2;				// Shadow depth texture 2
uniform float		uShadowMapSize[3];			// Size of shadow texture
uniform vec3		uShadowClipValues[3];		// Near & far clipping planes of the cameras
const int			cMaxCascades	= 3;

uniform float		uShadowPower;				// Power to increase shadow strength
uniform float		uShadowTreshold;			// Smoothstep treshold for maximum shadow strength

const float cCamDistanceFactor	= 4.0;
const int cSampleCount			= 24;
const float cSampleStep			= 1.0 / float( cSampleCount );

// Unpack depth
float get_depth( vec3 v ) {
    float val = ( v.r ) + ( v.g / 255.0 ) + ( v.b / ( 255.0 * 255.0 ));
    return ( 1.0 - val );

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

float inverse_pow( float a, float b ) {
	return 1.0 - pow( 1.0 - a, b );
}

void main()
{
	gl_FragColor = vec4( 1.0 );
	
	// Sample blue noise
	vec2 blueNoiseUv = mod( gl_FragCoord.xy, 128.0 ) / 128.0;
	float blueNoise = texture2D( uNoiseTexture, get_texture_coord( blueNoiseUv, uTexCoord )).b;
	
	vec4 fragColour = texture2D( gm_BaseTexture, v_vTexCoord );
	float fragDepth = min( get_depth( fragColour.rgb ) * cCamDistanceFactor, 1.0 );
	
	vec3 viewRay		= normalize( v_vViewRay );
	vec3 rayEndPosition = v_vCamPosition + ( viewRay * uCamFar * fragDepth ) / cCamDistanceFactor;

	
	// Shadow sampling
	int		plane = -1;
	int		p;
	vec4	shadowMapCoord;
	float	bias, depth_bias, linear_depth, shadow;
	vec4	shadow_coord;
	float	shadowMapRange0 = uShadowClipValues[0].z;
	float	shadowedSamples = 0.0;
	
	// Fog value
	float n;
	float total_value = 0.0;
	
	// Noise sampling
	float noise_value, sample_value, xy_value, yz_value, xz_value;
	float baseSampleValue = fragDepth * cSampleStep;
	//float sampleStep = fragDepth / float( cSampleCount );
	
	vec4 outValue = vec4( 0.0 );
	
	n = cSampleStep * blueNoise;
	
	for ( int i = 1; i < cSampleCount; i ++ ) {
		
	
	
		vec3 worldPos = mix( v_vCamPosition, rayEndPosition, n );
		n += cSampleStep;
		
		sample_value = baseSampleValue;
		
		// Noise sampling
		xy_value = texture2D( uNoiseTexture, get_texture_coord( vec2( worldPos.x, worldPos.y ) * 0.00051 * 0.5, uTexCoord )).g;
		xz_value = texture2D( uNoiseTexture, get_texture_coord( vec2( worldPos.x, worldPos.z ) * 0.00063 * 0.5, uTexCoord )).g;
		yz_value = texture2D( uNoiseTexture, get_texture_coord( vec2( worldPos.y, worldPos.z ) * 0.00047 * 0.5, uTexCoord )).g;
		
		noise_value		= xy_value * xz_value * yz_value;
		sample_value	*= inverse_pow( noise_value, 5.0 );
		sample_value	= max( sample_value, cSampleStep * 0.2 );
		
		//if ( sample_value < 0.01 ) continue;
		
		// Shadows
		// Choose closest shadow cascade
		if ( uEnableShadows == 1.0 ) {

			for ( p = 0; p < cMaxCascades; p += 1 ) {
		
				shadow_coord	= uDepthMatrix[p] * vec4( worldPos, 1.0 );
			
				// Get coordinate in shadow map space
				shadowMapCoord.xy = shadow_coord.xy / shadow_coord.w * 0.5 + 0.5;
				shadowMapCoord.z = shadow_coord.z;
				shadowMapCoord.w = shadow_coord.w;
				
		
				// Check that the position is inside the cascade  -- TODO: Change this to use DEPTH instead of XY
			    if ( shadowMapCoord.x >= 0.0 && shadowMapCoord.y >= 0.0 && shadowMapCoord.x <= 1.0 && shadowMapCoord.y <= 1.0 ) {
			
					plane = p;
					break;
				}
			}
		
			// Sample shadow plane
			if ( plane != -1 ) { 
		
				shadow		= 0.0;
				
				// Depth in shadow map space
				linear_depth		= ( shadowMapCoord.z / shadowMapCoord.w );

				if ( plane == 0 ) depth_bias = 0.0005;
				if ( plane == 1 ) depth_bias = 0.0001;
				if ( plane == 2 ) depth_bias = 0.00001;
				
				float bias = depth_bias;
				
				float shadow_depth = 0.0;
		
				if ( plane == 0 )		shadow_depth = get_depth( texture2D( uShadowMap0, shadowMapCoord.xy ).rgb );
				if ( plane == 1 )		shadow_depth = get_depth( texture2D( uShadowMap1, shadowMapCoord.xy ).rgb );
				if ( plane == 2 )		shadow_depth = get_depth( texture2D( uShadowMap2, shadowMapCoord.xy ).rgb );
			
				float depth_diff = linear_depth - shadow_depth;
				
				shadow = shadow_depth < linear_depth - bias ? 1.0 : 0.0;
				
				// Depth difference fade
				if ( shadow > 0.0 ) {
					
					// Calculate shadow surface position in world space
					float shadowMapRangeP	= uShadowClipValues[plane].z;
				
					float lim = 0.05 * shadowMapRange0 / shadowMapRangeP;
					lim = smoothstep( 0.0, lim, depth_diff );
					
					shadow -= lim;	
					shadow = max( 0.0, shadow );
				
				}
				
				//sample_value -= max( 0.0, shadow * 0.5 );
				
				shadowedSamples += shadow;
				
				// Bdebug
				//if ( shadow > 0.0 ) {
					
				//	if ( plane == 0 ) outValue = vec4( 1.0, 0.0, 0.0, 1.0 );
				//	if ( plane == 1 ) outValue = vec4( 0.0, 1.0, 0.0, 1.0 );
				//	if ( plane == 2 ) outValue = vec4( 0.0, 0.0, 1.0, 1.0 );
					
				//	//outValue = vec4( vec3( linear_depth ), 1.0 );
				//	break;
				//}
				
			}
		}
		
		total_value += sample_value;
		
	}
	
	float shadowedValue = shadowedSamples * cSampleStep;	// Percentage of shadowed samples out of all <cSampleCount> samples
	shadowedValue		= inverse_pow( shadowedValue, uShadowPower );			// Control shadow strength
	shadowedValue		= smoothstep( 0.0, uShadowTreshold, shadowedValue );	// Control the treshold for maximum shadow strength
	
	total_value *= 1.0 - shadowedValue;						// Multiply the total fog value by the inverse of the shadowed value
	
	// Fog colour by light colour
	float val		= max( 0.0, dot( viewRay, -uLightDirection ));
	vec3 fogColour	= mix( v_vColour.rgb * 0.5, uLightColour.rgb, pow( val, 5.0 ));
	
	vec4 outColour = vec4( fogColour.rgb, total_value );
	
	// TEST OUTPUT
	//outColour = vec4( vec3( total_value ), 1.0 );
	
	//if ( plane == 0 ) outColour = vec4( 1.0, 0.0, 0.0, 1.0 );
	//if ( plane == 1 ) outColour = vec4( 0.0, 1.0, 0.0, 1.0 );
	//if ( plane == 2 ) outColour = vec4( 0.0, 0.0, 1.0, 1.0 );

	gl_FragColor = outColour; 
	
}
