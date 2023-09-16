package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUINumericStepper;
import openfl.display.BitmapData;
import flixel.util.FlxCollision;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.net.FileReference;
import openfl.net.FileFilter;
import openfl.events.Event;
import flash.display.Bitmap;

class PopUp extends FlxSubState {
    var img:FlxSprite;
    var buttons:FlxTypedGroup<FlxSprite>;
    var mouseobject:FlxSprite;

    //number input stuff
    var coolwidth:FlxUINumericStepper;
    var coolheight:FlxUINumericStepper;

    override public function create() {
        //make mouse object
		mouseobject = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		add(mouseobject);

        var background:FlxSprite = new FlxSprite(349, 184).loadGraphic(Paths.returnimage('popup/background'));
		add(background);

        buttons = new FlxTypedGroup<FlxSprite>();
		add(buttons);

        var existing:FlxSprite = new FlxSprite(669, 337).loadGraphic(Paths.returnimage('popup/existing'));
		existing.ID = 0;
		buttons.add(existing);

		var back:FlxSprite = new FlxSprite(370, 487).loadGraphic(Paths.returnimage('popup/back'));
		back.ID = 1;
		buttons.add(back);

		var newbutton:FlxSprite = new FlxSprite(782, 481).loadGraphic(Paths.returnimage('popup/new'));
		newbutton.ID = 2;
		buttons.add(newbutton);

        coolwidth = new FlxUINumericStepper(480, 320, 10, 1200, 0, 10000, 0);
        add(coolwidth);

        coolheight = new FlxUINumericStepper(480, 385, 10, 665, 0, 10000, 0);
        add(coolheight);

        super.create();
    }

    override public function update(elapsed:Float) {
        mouseobject.x = FlxG.mouse.x;
		mouseobject.y = FlxG.mouse.y;

        buttons.forEach(function(button:FlxSprite) {
			button.color = 0xFFBFBFBF;
			if(FlxCollision.pixelPerfectCheck(mouseobject, button, 1)) {
				button.color = 0xFFFFFFFF;
				if(FlxG.mouse.justPressed) {
					switch(button.ID) {
						case 0:
                            showFileDialog();
						case 1:
                            DrawState.redrawimage = false;
							close();
						case 2:
                            DrawState.width = Math.round(coolwidth.value);
                            DrawState.height = Math.round(coolheight.value);
                            DrawState.image = false;
                            DrawState.redrawimage = true;
                            close();
					}
				}
			}
		});
        
        super.update(elapsed);
    }

    function showFileDialog() {
        var fr:FileReference = new FileReference();
        fr.addEventListener(Event.SELECT, onSelect, false, 0, true);
        var filters:Array<FileFilter> = new Array<FileFilter>();
        filters.push(new FileFilter("PNG Files", "*.png"));
        filters.push(new FileFilter("JPEG Files", "*.jpg;*.jpeg"));
        fr.browse();
    }
    
    function onSelect(E:Event) {
        var fr:FileReference = cast(E.target, FileReference);
        fr.addEventListener(Event.COMPLETE, onLoad, false, 0, true);
        fr.load();
    }
    
    function onLoad(E:Event) {
        var fr:FileReference = cast E.target;
        fr.removeEventListener(Event.COMPLETE, onLoad);
    
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImgLoad);
        loader.loadBytes(fr.data);
    }
    
    function onImgLoad(E:Event) {
        var loaderInfo:LoaderInfo = cast E.target;
        loaderInfo.removeEventListener(Event.COMPLETE, onImgLoad);
        var bmp:Bitmap = cast(loaderInfo.content, Bitmap);
        theimagething(bmp.bitmapData);
    }

    function theimagething(coolimage:BitmapData) {
        DrawState.image = true;
        DrawState.imagething = coolimage;
        DrawState.redrawimage = true;
        close();
    }
}
