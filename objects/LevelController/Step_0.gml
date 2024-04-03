/// @description Update lighting


global.updateShaderFlags.lighting = true;
Level.lightDirection = vector_rotate_axis( Level.lightDirection, Level.up, 10 * DELTA );