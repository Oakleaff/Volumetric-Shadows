//
// Simple passthrough fragment shader
//

#define pi 3.14159265359

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vPosition;

uniform vec4 uColour0;
uniform vec4 uColour1;

uniform vec3	uLightDirection;

uniform float	uTexCoord[4];



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

float inverse_pow( float aa, float bb ) {
	return ( 1.0 - pow( 1.0 - aa, bb ));
}



void main()
{
	
	vec3 normal	= normalize( v_vPosition );

	float val = dot( normal, -uLightDirection );
	val = ( val + 1.0 ) * 0.5;
	
	vec4 colour = mix( uColour0, uColour1, val );
	
	// Sun disk
	float sun = dot( normal, -uLightDirection );
	float emission = smoothstep( 0.9, 1.0, sun ) * 0.5;
	sun = smoothstep( 0.9998, 0.9999, sun ) * 2.0;
	
	colour = mix( colour, vec4( 1.0 ), sun );

	
    gl_FragData[0] = colour;
 
}
