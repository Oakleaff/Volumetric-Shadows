//
// Simple passthrough fragment shader
//
varying vec2	v_vTexCoord;
varying vec4	v_vColour;
varying float	v_vDepth;

const float cAlphaCutoff = 0.5;

uniform float		uTexCoord[4];

vec3 pack_depth( float f ) {
    return vec3( floor( f * 255.0 ) / 255.0, fract( f * 255.0 ), fract( f * 255.0 * 255.0 ) );
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

void main()
{
	
	vec4 texColour	= texture2D( gm_BaseTexture, get_texture_coord( v_vTexCoord, uTexCoord ) );
	if ( texColour.a < cAlphaCutoff ) discard; 
	
	float depth = v_vDepth;
	
	vec4 colour;
	
	// PACK DEPTH
	colour.rgb	= pack_depth( v_vDepth );
	colour.a	= 1.0;
	
    gl_FragColor	= colour;
	
	// Debug depth
	//gl_FragColor	= vec4( depth, depth, depth, 1.0 );
}
