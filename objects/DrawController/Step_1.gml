/// @description Update

if ( keyboard_check_pressed( vk_escape )) game_end();

if  ( keyboard_check_pressed( vk_f12 )) {
	drawDebug = !drawDebug;
	show_debug_overlay( drawDebug );
}

if  ( keyboard_check_pressed( vk_f1 )) drawDepthBuffer = !drawDepthBuffer;
if  ( keyboard_check_pressed( vk_f2 )) drawShadowMaps = !drawShadowMaps;



