package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.input.mouse.FlxMouse;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.util.FlxCollision;
import openfl.utils.ByteArray;
import haxe.io.Bytes;
import openfl.display.PNGEncoderOptions;
import flash.net.FileReference;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.geom.Point;

class DrawState extends FlxState {
	//mouse stuff
	var mouseobject:FlxSprite;
	var mousepos:FlxPoint;
	var oldmousepos:FlxPoint;

	//camera stuff
	var cam:FlxCamera;
	var camfollow:FlxObject;

	//drawing stuff
	var size = 6.0;
	var curcolor = 0xFF000000;
	var start:FlxPoint;
	var released = false;
	var justreleased = false;
	var drawing = false;
	public static var width = 1200;
	public static var height = 665;
	public static var imagebool = false;
	public static var imagething:BitmapData;
	public static var redrawimage = false;
	var undostuff = false;
	var drawingimage:FlxSprite;
	var drawingimageold:FlxSprite;
	var drawingsquare:FlxSprite;
	var drawingcircle:FlxSprite;

	//buttons
	//var buttons:FlxTypedGroup<FlxSprite>;
	var otherbuttons:FlxTypedGroup<FlxSprite>;
	var thingmakingmemad = ['brush', 'bucket', 'square', 'circle'];
	var curoption = 0;

	//text fields and stuff
	var coolred:FlxUINumericStepper;
	var coolgreen:FlxUINumericStepper;
	var coolblue:FlxUINumericStepper;
	var coolsize:FlxUINumericStepper;

	override public function create() {
		//default mouse
		FlxG.mouse.useSystemCursor = true;

		//make mouse object
		mouseobject = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		add(mouseobject);

		//make camera
		cam = new FlxCamera(70, 45, width, height, 1.0);
		//FlxG.cameras.add(cam);
		camfollow = new FlxObject(0, 0, 1, 1);
		add(camfollow);
		//FlxG.camera.follow(camfollow, LOCKON, 1);

		//make the images

		drawingimageold = new FlxSprite(70, 45).makeGraphic(width, height, 0xFFFFFFFF);
		add(drawingimageold);

		drawingimage = new FlxSprite(70, 45).makeGraphic(width, height, 0xFFFFFFFF);
		//drawingimage.cameras = [cam];
		add(drawingimage);

		drawingsquare = new FlxSprite();
		add(drawingsquare);

		drawingcircle = new FlxSprite();
		add(drawingcircle);

		//make bg
		var background:FlxSprite = new FlxSprite().loadGraphic(Paths.returnimage('background'));
		add(background);

		/*
		buttons = new FlxTypedGroup<FlxSprite>();
		add(buttons);
		*/

		otherbuttons = new FlxTypedGroup<FlxSprite>();
		add(otherbuttons);

		//make buttons
		/*
		for(i in 0...4) {
			var button:FlxSprite = new FlxSprite(4, 45 + (i * 67)).loadGraphic(Paths.returnimage(thingmakingmemad[i]));
			button.ID = i;
			buttons.add(button);
		}
		*/

		var newbutton:FlxSprite = new FlxSprite(69, 1).loadGraphic(Paths.returnimage('new'));
		newbutton.ID = 0;
		otherbuttons.add(newbutton);

		/*
		var newbutton:FlxSprite = new FlxSprite(195, 3).loadGraphic(Paths.returnimage('save'));
		newbutton.ID = 1;
		otherbuttons.add(newbutton);

		var redobutton:FlxSprite = new FlxSprite(377, 4).loadGraphic(Paths.returnimage('redo'));
		redobutton.ID = 3;
		otherbuttons.add(redobutton);
		*/

		var undobutton:FlxSprite = new FlxSprite(326, 5).loadGraphic(Paths.returnimage('undo'));
		undobutton.ID = 1;
		otherbuttons.add(undobutton);

		coolred = new FlxUINumericStepper(565, 16, 1, 0, 0, 255, 3);
		add(coolred);

		coolgreen = new FlxUINumericStepper(coolred.x + coolred.width + 5, 16, 1, 0, 0, 255, 3);
		add(coolgreen);

		coolblue = new FlxUINumericStepper(coolgreen.x + coolgreen.width + 5, 16, 1, 0, 0, 255, 3);
		add(coolblue);

		coolsize = new FlxUINumericStepper(1142, 16, 0.5, 6, 0, 999, 3);
		add(coolsize);

		super.create();
	}

	override public function update(elapsed:Float) {
		size = coolsize.value;
		if(0 >= size) {
			size = 0.5;
		}
		curcolor = FlxColor.fromRGBFloat(coolred.value / 255, coolgreen.value / 255, coolblue.value / 255, 1);

		/*
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
		*/

		mouseobject.x = FlxG.mouse.x;
		mouseobject.y = FlxG.mouse.y;

		oldmousepos = mousepos;
		mousepos = FlxG.mouse.getWorldPosition();

		if(FlxG.mouse.justPressed) {
			start = mousepos;
			released = false;
			justreleased = false;
			if(FlxG.mouse.x >= 70 && FlxG.mouse.x <= 1275 && FlxG.mouse.y >= 45 && FlxG.mouse.y <= 715 && FlxCollision.pixelPerfectCheck(mouseobject, drawingimage, 1)) {
				drawing = true;
				var thing = drawingimage.pixels;
				FlxSpriteUtil.fill(drawingimageold, 0xFFFFFFFF);
				drawingimageold.pixels.copyPixels(thing, thing.rect, new Point(0, 0), null, null, true);
				undostuff = true;
			} else {
				drawing = false;
			}
		}

		/*
		buttons.forEach(function(button:FlxSprite) {
			button.color = 0xFFBFBFBF;
			if(FlxCollision.pixelPerfectCheck(mouseobject, button, 1)) {
				button.color = 0xFFFFFFFF;
				if(FlxG.mouse.justPressed) {
					curoption = button.ID;
				}
			}
		});
		*/
		
		otherbuttons.forEach(function(button:FlxSprite) {
			button.color = 0xFFBFBFBF;
			if(FlxCollision.pixelPerfectCheck(mouseobject, button, 1)) {
				button.color = 0xFFFFFFFF;
				if(FlxG.mouse.justPressed) {
					switch(button.ID) {
						case 0:
							FlxSpriteUtil.fill(drawingimage, 0xFFFFFFFF);
							FlxSpriteUtil.fill(drawingimageold, 0xFFFFFFFF);
							undostuff = false;
							/*
							var tempState:PopUp = new PopUp();
							openSubState(tempState);
							*/
						case 1:
							if(undostuff) {
								var thing = drawingimageold.pixels;
								FlxSpriteUtil.fill(drawingimage, 0xFFFFFFFF);
								drawingimage.pixels.copyPixels(thing, thing.rect, new Point(0, 0), null, null, true);
								undostuff = false;
							}
						case 2:
							var byteArray:ByteArray = new ByteArray();
							//bitmapdata1.encode(bitmapdata1.rect, new PNGEncoderOptions(false), byteArray);
							byteArray.compress();
							byteArray.uncompress();
							var savefile = new FileReference();
							savefile.save(Bytes.ofData(byteArray), "untitled.png");
					}
				}
			}
			if(button.ID == 1) {
				button.visible = undostuff;
			}
		});
	
		if(FlxG.mouse.justReleased) {
			released = true;
			drawing = false;
			if(drawing) {
				justreleased = true;
			}
		}

		if(drawing) {
			switch(curoption) {
				case 0:
					var image = new FlxSprite();
					FlxSpriteUtil.drawLine(drawingimage, mousepos.x - 70, mousepos.y - 45, oldmousepos.x - 70, oldmousepos.y - 45, {thickness: size * 2, color: curcolor});
					if(justreleased) {
						drawing = false;
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
					if(justreleased) {
						justreleased = false;
						drawing = false;
						FlxSpriteUtil.drawRect(drawingimage, coolx, cooly, width, height, curcolor, {thickness: size, color: curcolor});
					} else {
						var image = new FlxSprite();
						FlxSpriteUtil.drawRect(image, coolx, cooly, width, height, curcolor, {thickness: size, color: curcolor});
						drawingsquare = image;
					}
				case 3:
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
					if(justreleased) {
						justreleased = false;
						drawing = false;
						FlxSpriteUtil.drawEllipse(drawingimage, coolx, cooly, width, height, curcolor, {thickness: size, color: curcolor});
					} else {
						var image = new FlxSprite();
						FlxSpriteUtil.drawEllipse(image, coolx, cooly, width, height, curcolor, {thickness: size, color: curcolor});
						drawingcircle = image;
					}
			}
		}

		super.update(elapsed);
	}

	function stampthing(coolpixels:BitmapData, coolx, cooly) {
		var image:FlxSprite = new FlxSprite(Math.round(coolx), Math.round(cooly));
		image.pixels = coolpixels;
		drawingimage.stamp(image);
	}

	function powerthing(numlol:Float, power:Int) {
		var finalthing = 1.0;
		for(i in 0...power) {
			finalthing *= numlol;
		}
		return finalthing;
	}
}
