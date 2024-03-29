//
// Simple passthrough fragment shader
//
varying vec2 v_vTexCoord;
varying vec4 v_vColour;
varying vec3 v_vPosition;


// Material
uniform vec4		uFadeColour;
uniform float		uTexCoord[4];

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
	
	vec4 colour = v_vColour * texture2D( gm_BaseTexture, get_texture_coord( v_vTexCoord, uTexCoord ));
	
	if ( colour.a < 0.2 ) discard;
	
	// Fade colour
	if ( uFadeColour.a > 0.0 ) colour.rgb = mix( colour.rgb, uFadeColour.rgb, uFadeColour.a );
	
    gl_FragData[0] = colour;
}
