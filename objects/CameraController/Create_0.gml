/// @description

// Set global camera
globalvar Camera;
Camera = instance_create( 0, 0, oCamera );

cameraList	= [];
cameraCount = 0;

with ( oCamera ) array_push( CameraController.cameraList, id );
cameraCount = array_length( cameraList );

global.loadState[ CameraController ] = true;