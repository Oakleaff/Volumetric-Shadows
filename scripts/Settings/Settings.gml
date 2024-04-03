

global.__settings = {};
#macro	SETTINGS				global.__settings
#macro	SETTINGS_DEFAULT_PATH	SETTINGS.fileSystem.defaultPath
#macro	SETTINGS_MAX_LIGHTS		SETTINGS.graphics.maxLightCount

SETTINGS.audio		= {};
SETTINGS.graphics	= {};
SETTINGS.fileSystem = {};

with ( SETTINGS.graphics ) {
	renderGeometry	= true;
	renderInstances	= true;
	renderDebug		= true;
	renderOutlines	= false;
	renderFog		= false;
	
	enableShadows	= true;
	
	maxLightCount	= 24;
}

with ( SETTINGS.fileSystem ) {
	
	defaultPath = "C:/Users/"
	
	
}