package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.input.mouse.FlxMouse;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.util.FlxCollision;
import openfl.utils.ByteArray;
import haxe.io.Bytes;
import openfl.display.PNGEncoderOptions;
import flash.net.FileReference;
import flixel.FlxObject;
import flixel.util.FlxColor;

class DrawState extends FlxState {
	//bitmapdata
	var bitmapdata1:BitmapData;
	var bitmapdata2:BitmapData;
	var bitmapdata3:BitmapData;
	var bitmapdata4:BitmapData;
	var bitmapdata5:BitmapData;

	//mouse stuff
	var mouseobject:FlxSprite;
	var mousepos:FlxPoint;
	var oldmousepos:FlxPoint;

	//camera stuff
	var cam:FlxCamera;
	var camfollow:FlxObject;

	//drawing stuff
	var size = 1.0;
	var curcolor = 0xFF444444;
	var start:FlxPoint;
	var released = false;
	var justreleased = false;
	var drawing = false;
	public static var width = 1200;
	public static var height = 665;
	public static var image = false;
	public static var imagething:BitmapData;
	public static var redrawimage = false;
	var undostuff = 4;
	var redostuff = 0;
	var drawingimage:FlxSprite;

	//buttons
	var buttons:FlxTypedGroup<FlxSprite>;
	var otherbuttons:FlxTypedGroup<FlxSprite>;
	var thingmakingmemad = ['brush', 'bucket', 'square', 'circle'];
	var curoption = 0;

	//text fields and stuff
	var coolcolor:FlxUIInputText;
	var coolsize:FlxUINumericStepper;

	override public function create() {
		//default mouse
		FlxG.mouse.useSystemCursor = true;

		//make mouse object
		mouseobject = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		add(mouseobject);

		//load image
		loadimage();

		//make camera
		cam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1.0);
		//FlxG.cameras.add(cam);
		camfollow = new FlxObject(0, 0, 1, 1);
		add(camfollow);
		//FlxG.camera.follow(camfollow, LOCKON, 1);

		//make the image
		drawingimage = new FlxSprite(70, 45);
		drawingimage.pixels = bitmapdata1;
		//drawingimage.cameras = [cam];
		add(drawingimage);

		//make bg
		var background:FlxSprite = new FlxSprite().loadGraphic(Paths.returnimage('background'));
		add(background);

		buttons = new FlxTypedGroup<FlxSprite>();
		add(buttons);

		otherbuttons = new FlxTypedGroup<FlxSprite>();
		add(otherbuttons);

		//make buttons
		for(i in 0...4) {
			var button:FlxSprite = new FlxSprite(4, 45 + (i * 67)).loadGraphic(Paths.returnimage(thingmakingmemad[i]));
			button.ID = i;
			buttons.add(button);
		}

		var newbutton:FlxSprite = new FlxSprite(69, 1).loadGraphic(Paths.returnimage('new'));
		newbutton.ID = 0;
		otherbuttons.add(newbutton);

		var newbutton:FlxSprite = new FlxSprite(195, 3).loadGraphic(Paths.returnimage('save'));
		newbutton.ID = 1;
		otherbuttons.add(newbutton);

		var undobutton:FlxSprite = new FlxSprite(326, 5).loadGraphic(Paths.returnimage('undo'));
		undobutton.ID = 2;
		otherbuttons.add(undobutton);

		var redobutton:FlxSprite = new FlxSprite(377, 4).loadGraphic(Paths.returnimage('redo'));
		redobutton.ID = 3;
		otherbuttons.add(redobutton);

		coolcolor = new FlxUIInputText(565, 16, 142, '444444');
		add(coolcolor);

		coolsize = new FlxUINumericStepper(1142, 16, 0.5, 1, 0, 999, 3);
		add(coolsize);

		super.create();
	}

	override public function update(elapsed:Float) {
		size = coolsize.value;
		var valthing = coolcolor.name;
		curcolor = FlxColor.fromString('#' + valthing);

		var speed = 5;
		if(FlxG.keys.pressed.W || FlxG.keys.pressed.UP) {
			drawingimage.y += speed;
		}
		if(FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN) {
			drawingimage.y -= speed;
		}
		if(FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
			drawingimage.x += speed;
		}
		if(FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT) {
			drawingimage.x -= speed;
		}

		if(FlxG.mouse.wheel != 0) {
			cam.zoom += FlxG.mouse.wheel / 10;
		}

		mouseobject.x = FlxG.mouse.x;
		mouseobject.y = FlxG.mouse.y;

		oldmousepos = mousepos;
		mousepos = FlxG.mouse.getScreenPosition();

		if(FlxG.mouse.justPressed) {
			start = mousepos;
			released = false;
			justreleased = false;
			if(FlxG.mouse.x >= 70 && FlxG.mouse.x <= 1275 && FlxG.mouse.y >= 45 && FlxG.mouse.y <= 715) {
				if(FlxCollision.pixelPerfectCheck(mouseobject, drawingimage, 1)) {
					drawing = true;
				} else {
					drawing = false;
				}
			} else {
				drawing = false;
			}
		}

		buttons.forEach(function(button:FlxSprite) {
			button.color = 0xFFBFBFBF;
			if(FlxCollision.pixelPerfectCheck(mouseobject, button, 1)) {
				button.color = 0xFFFFFFFF;
				if(FlxG.mouse.justPressed) {
					curoption = button.ID;
				}
			}
		});

		otherbuttons.forEach(function(button:FlxSprite) {
			button.color = 0xFFBFBFBF;
			if(FlxCollision.pixelPerfectCheck(mouseobject, button, 1)) {
				button.color = 0xFFFFFFFF;
				if(FlxG.mouse.justPressed) {
					switch(button.ID) {
						case 0:
							var tempState:PopUp = new PopUp();
							openSubState(tempState);
						case 1:
							var byteArray:ByteArray = new ByteArray();
							bitmapdata1.encode(bitmapdata1.rect, new PNGEncoderOptions(false), byteArray);
							byteArray.compress();
							byteArray.uncompress();
							var savefile = new FileReference();
							savefile.save(Bytes.ofData(byteArray), "untitled.png");
						case 2:
							undostuff -= 1;
							if(undostuff < 0) {
								undostuff = 0;
							} else {
								redostuff += 1;
								var bufferbitmap:BitmapData = bitmapdata1;
								bitmapdata1 = bitmapdata2;
								bitmapdata2 = bitmapdata3;
								bitmapdata3 = bitmapdata4;
								bitmapdata4 = bitmapdata5;
								bitmapdata5 = bufferbitmap;
							}
						case 3:
							redostuff -= 1;
							if(redostuff < 0) {
								redostuff = 0;
							} else {
								undostuff += 1;
								var bufferbitmap:BitmapData = bitmapdata5;
								bitmapdata5 = bitmapdata4;
								bitmapdata4 = bitmapdata3;
								bitmapdata3 = bitmapdata2;
								bitmapdata2 = bitmapdata1;
								bitmapdata1 = bufferbitmap;
							}
					}
				}
			}
		});
	
		if(FlxG.mouse.justReleased) {
			released = true;
			drawing = false;
			if(drawing) {
				justreleased = true;
				undostuff = 4;
				redostuff = 0;
				bitmapdata5 = bitmapdata4;
				bitmapdata4 = bitmapdata3;
				bitmapdata3 = bitmapdata2;
				bitmapdata2 = bitmapdata1;
			}
		}

		if(drawing) {
			switch(curoption) {
				case 0:
					var repeat = Math.round(Math.sqrt(powerthing(mousepos.x - oldmousepos.x, 2) + powerthing(mousepos.y - oldmousepos.y, 2)));
					for(i in 0...repeat) {
						var rad = size / 2;
						var coolx = ((mousepos.x / repeat) * (repeat - i)) - ((oldmousepos.x / repeat) * i);
						var cooly = start.y;
						if(rad < 0) {
							rad = -rad;
							coolx -= rad;
							cooly -= rad;
						}
						var circle = new FlxShapeCircle(coolx, start.y, rad, {}, curcolor);
						stampthing(circle.pixels, coolx, cooly);
					}
				case 1:
	
				case 2:
					var width = mousepos.x - start.x;
					var coolx = start.x;
					if(width < 0) {
						width = -width;
						coolx -= width;
					}
					var height = mousepos.y - start.y;
					var cooly = start.y;
					if(height < 0) {
						height = -height;
						cooly -= height * 2;
					}
					var square = new FlxShapeBox(coolx, cooly, width, height, {thickness: size, color: curcolor}, 0x00000000);
					if(justreleased) {
						justreleased = false;
					}
					stampthing(square.pixels, coolx, cooly);
				case 3:
					var rad = (mousepos.x - start.x) / 2;
					var coolx = start.x;
					var cooly = start.y;
					if(rad < 0) {
						rad = -rad;
						coolx -= rad * 2;
						cooly -= rad * 2;
					}
					var circle = new FlxShapeCircle(coolx, cooly, rad, {thickness: size, color: curcolor}, 0x00000000);
					if(justreleased) {
						justreleased = false;
					}
					stampthing(circle.pixels, coolx, cooly);
			}
		}

		if(redrawimage) {
			loadimage();
		}
		drawingimage.pixels = bitmapdata1;

		super.update(elapsed);
	}

	function stampthing(pixels:BitmapData, coolx, cooly) {
		var image:FlxSprite = new FlxSprite(Math.round(coolx), Math.round(cooly));
		image.pixels = pixels;
		drawingimage.stamp(image);
		bitmapdata1 = drawingimage.pixels;
	}

	function powerthing(numlol:Float, power:Int) {
		var finalthing = 1.0;
		for(i in 0...power) {
			finalthing *= numlol;
		}
		return finalthing;
	}

	function loadimage() {
		if(image) {
			bitmapdata1 = imagething;
		} else {
			var image = new FlxSprite().makeGraphic(width, height, 0xFFCCCCC);
			bitmapdata1 = image.pixels;
		}
		bitmapdata2 = bitmapdata1;
		bitmapdata3 = bitmapdata1;
		bitmapdata4 = bitmapdata1;
		bitmapdata5 = bitmapdata1;
		redrawimage = false;
	}
}
