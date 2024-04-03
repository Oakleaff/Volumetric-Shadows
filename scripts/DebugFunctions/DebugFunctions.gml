include( "DebugFunctions" );
require( "VertexFunctions" );

/// @function debug_init();
function debug_init() {

	globalvar debug_time;
	debug_time = 0;
	
	
	global.debugMesh = vertex_create_buffer();
	vertex_begin( global.debugMesh, VERTEXFORMAT );
		
		vbuffer_add_line( global.debugMesh, 0, 0, 0, 100, 0, 0, c_red, 1, c_red, 1 );
		vbuffer_add_line( global.debugMesh, 0, 0, 0, 0, 100, 0, c_lime, 1, c_lime, 1 );
		vbuffer_add_line( global.debugMesh, 0, 0, 0, 0, 0, 100, c_aqua, 1, c_aqua, 1 );

	vertex_end_freeze( global.debugMesh );
	
	global.blenderDebugMesh = vertex_create_buffer();
	vertex_begin( global.blenderDebugMesh, VERTEXFORMAT );
		
		vbuffer_add_line( global.blenderDebugMesh, 0, 0, 0, 0, -10, 0, c_red, 1, c_red, 1 );
		vbuffer_add_line( global.blenderDebugMesh, 0, 0, 0, 10, 0, 0, c_lime, 1, c_lime, 1 );
		vbuffer_add_line( global.blenderDebugMesh, 0, 0, 0, 0, 0, 10, c_aqua, 1, c_aqua, 1 );

	vertex_end_freeze( global.blenderDebugMesh );


} 


/// @function debug_log( vars )
function debug_log( vars ) {
	
	var eventType = "Event";
	switch ( event_type ) {
		case ev_create:		eventType = "Create";		break;
		case ev_destroy:	eventType = "Destroy";		break;
		case ev_step:		eventType = "Step";			break;
		case ev_alarm:		eventType = "Alarm";		break;
		case ev_keyboard:	eventType = "Keyboard";		break;
		case ev_keypress:	eventType = "Keypress";		break;
		case ev_keyrelease:	eventType = "Keyrelease";	break;
		case ev_mouse:		eventType = "Mouse";		break;
		case ev_collision:	eventType = "Collision";	break;
		case ev_other:		eventType = "Other";		break;
		case ev_draw:		eventType = "Draw";			break;
	}
	
	var output = object_get_name( object_index ) + "|" + eventType + "|" + string( event_number );
	
	for( var i = 0; i < argument_count; i ++  ) {
		output += "|" + string( argument[i] );
	}
	
	log( output );
	
}



/// @function debug_timer_start()
function debug_timer_start(){
	debug_time = get_timer();
}

/// @function debug_timer_log( string* );
/// @param *string
function debug_timer_log( str = "", reset = true ){
	var time = get_timer() - debug_time;
	
	if ( str != "" ) {
		log( str + " " + string_format( time / 1000, 10, 5 ) + " ms" );
	}
	else {
		log( string( time / 1000 ) + " ms" );
	}
	
	if ( reset ) debug_timer_start();
}

/// @function debug_timer_get()
function debug_timer_get(){
	return get_timer() - debug_time;
}

/// @function debug_draw_line( x1, y1, z1, x2, y2, z2, *colour )
/// @arg x1
/// @arg y1
/// @arg z1
/// @arg x2
/// @arg y2
/// @arg z2
/// @arg *colour0
/// @arg *colour1
function debug_draw_line() {

	var i = 0;
	var x1 = argument[i++];
	var y1 = argument[i++];
	var z1 = argument[i++];
	var x2 = argument[i++];
	var y2 = argument[i++];
	var z2 = argument[i++];

	var colour0 = c_fuchsia;
	var colour1 = c_fuchsia;
	if ( argument_count > i ) colour0 = argument[i++];
	if ( argument_count > i ) colour1 = argument[i++];
	
	var vertex = vertex_create_buffer();
	
	vertex_begin( vertex, VERTEXFORMAT );
		vbuffer_add_line( vertex, x1, y1, z1, x2, y2, z2, colour0, 1, colour1, 1 );
	vertex_end( vertex);
	vertex_freeze( vertex );
	
	vertex_submit( vertex, pr_linelist, -1 );
	
	vertex_delete_buffer( vertex );


}



