package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	var gameWidth = 1280;
	var gameHeight = 720;
	var initialState = DrawState;
	var updateFramerate = 60;
	var drawFramerate = 60;
	var skipSplash = false;
	var startFullscreen = false;

	public function new() {
		super();
		
		addChild(new FlxGame(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen));
	}
}
