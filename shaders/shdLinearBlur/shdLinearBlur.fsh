//
// Simple passthrough fragment shader
//

#define pi	3.14159265359

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2	uTexSize;
uniform float	uBlurRadius;
uniform vec2	uBlurDirection;

void main()
{
	
	vec2 texel_size = 1.0 / uTexSize * uBlurDirection;
	
	vec4 total_colour = vec4( 0.0 );
	vec4 texColour = texture2D( gm_BaseTexture, v_vTexcoord );
	
	for ( float i = -uBlurRadius; i <= uBlurRadius; i += 1.0 ) {
		total_colour += texture2D( gm_BaseTexture, v_vTexcoord + i * texel_size );	
	}
	
	total_colour /= 2.0 * ( uBlurRadius ) + 1.0;
	
	vec4 final_colour	= v_vColour * total_colour;
	//final_colour.a		= texColour.a;
	
    gl_FragColor = final_colour;
}
