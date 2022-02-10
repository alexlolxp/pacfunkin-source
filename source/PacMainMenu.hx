package;

import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;

using StringTools;

class PacMainMenu extends MusicBeatState //kinda just took the normal main menu and made some changes to its code, and it worked well lol\\
{
    public static var modVer:String = '1.0';
    public static var curSelected:Int = 0;
    var credNames:FlxText;

    var menuStuff:FlxTypedGroup<FlxText>;
    private var camGame:FlxCamera;

    var menuOptions:Array<String> = ['play!', 'freeplay', 'options'];

    var tetrisCode:Array<Dynamic> = [
		[FlxKey.T], 
		[FlxKey.E], 
		[FlxKey.T], 
		[FlxKey.R],
        [FlxKey.I],
		[FlxKey.S]];
	
    var tetrisCodeOrder:Int = 0;
    var logo:FlxSprite;

    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    override function create() 
    {
        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Main Menu", null);
		#end

        FlxG.game.focusLostFramerate = ClientPrefs.framerate;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		PlayerSettings.init();

        if (FlxG.sound.music == null)
            FlxG.sound.playMusic(Paths.music('freakyMenu'));

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		#end
		} else {
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		    #end
        #end
		}

        camGame = new FlxCamera();
        FlxG.cameras.reset(camGame);
        FlxCamera.defaultCameras = [camGame];

        transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

        persistentUpdate = persistentDraw = true;

        var bg:FlxSprite = new FlxSprite(-80).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLUE);
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg); //i'll switch this later\\

		var border:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('border'));
		border.scrollFactor.set();
		border.updateHitbox();
		border.screenCenter();
		border.antialiasing = ClientPrefs.globalAntialiasing;
		add(border);

        logo = new FlxSprite(0, 100).loadGraphic(Paths.image('pac-funkin'));
		logo.scrollFactor.set();
		logo.updateHitbox();
		logo.screenCenter(X);
		logo.antialiasing = false;
        logo.setGraphicSize(Std.int(logo.width * 0.5));
		add(logo);

        FlxTween.angle(logo, logo.angle, -2, 2, {ease: FlxEase.expoInOut});

		new FlxTimer().start(1, function(tmr:FlxTimer)
        {
                if (logo.angle == -2)
                    FlxTween.angle(logo, logo.angle, 2, 2, {ease: FlxEase.quartInOut});
                else
                    FlxTween.angle(logo, logo.angle, -2, 2, {ease: FlxEase.quartInOut});
        }, 0);

        menuStuff = new FlxTypedGroup<FlxText>();
        add(menuStuff);

        for (i in 0...menuOptions.length)
        {
            var menuThing:FlxText = new FlxText(0, 400);
            menuThing.text = menuOptions[i];
            menuThing.ID = i;
            menuStuff.add(menuThing);
            menuThing.scrollFactor.set();
            menuThing.antialiasing = false;
            menuThing.updateHitbox();
            menuThing.setFormat(Paths.font("emulogic.ttf"), 27, FlxColor.YELLOW, CENTER);
        }

        menuStuff.forEach(function(spr:FlxText)
            {
                switch (spr.ID)
                {
                    case 0:
                        spr.offset.y = 20;
                    case 1:
                        spr.offset.y = -20;
                    case 2:
                        spr.offset.y = -60;
                }

                if (spr.ID == curSelected)
                {
                    spr.color = FlxColor.RED;
                }
            }); // for positioning the buttons

        var versionShit:FlxText = new FlxText(162, FlxG.height - 190, 0, modVer, 12);
        versionShit.scrollFactor.set();
        versionShit.setFormat("Emulogic", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(versionShit);

        super.create();
    }
     
    var selectedThing:Bool = false;

    override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.ANY) 
        {
			var correctkeylol:Bool = false;
			for (i in 0...tetrisCode[tetrisCodeOrder].length) 
            {
				if (FlxG.keys.checkStatus(tetrisCode[tetrisCodeOrder][i], JUST_PRESSED))
					correctkeylol = true;
			}
			if (correctkeylol) 
            {
				if (tetrisCodeOrder == (tetrisCode.length - 1)) 
                {
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong('Mazes', 2), 'mazes');
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = 2;
					LoadingState.loadAndSwitchState(new PlayState());
				} 
                else 
                {
					tetrisCodeOrder++;		
			    }
			} 
            else 
            {
				tetrisCodeOrder = 0;
				for (i in 0...tetrisCode[0].length) 
                {
					if (FlxG.keys.checkStatus(tetrisCode[0][i], JUST_PRESSED))
						tetrisCodeOrder = 1;
				}
			}
		}

        if (!selectedThing)
        {
            if (controls.UI_UP_P)
            {
				changeItem(-1);
            }
            
            if (controls.UI_DOWN_P)
            {
                changeItem(1);
            }

            if (controls.BACK)
            {
                selectedThing = true;
                MusicBeatState.switchState(new TitleState());
            }

            if (controls.ACCEPT)
            {
                selectedThing = true;
                FlxG.sound.play(Paths.sound('confirmMenu'));

                menuStuff.forEach(function(spr:FlxText)
                {
                    FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
                    {
                        var items:String = menuOptions[curSelected];

                        switch (items)
                        {
                            case 'play!':
                                PlayState.SONG = Song.loadFromJson(Highscore.formatSong('Pellets', 2), 'pellets');
                                PlayState.isStoryMode = true;
                                PlayState.storyWeek = 1;
                                PlayState.storyDifficulty = 2;
                                PlayState.storyPlaylist = ['Pellets', 'Mazes'];
                                FreeplayState.destroyFreeplayVocals();
                                LoadingState.loadAndSwitchState(new PlayState());
                            case 'freeplay':
                                MusicBeatState.switchState(new FreeplayState());
                            case 'options':
                                MusicBeatState.switchState(new OptionsState());
                        }
                    });
                });
            }
            
            #if desktop
			if (FlxG.keys.justPressed.SEVEN)
			{
				selectedThing = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
        }

        super.update(elapsed);

        menuStuff.forEach(function(spr:FlxSprite)
            {
                spr.screenCenter(X);
            }); // might remove this later
    }

    function changeItem(skullemoji:Int = 0) 
    {
        curSelected += skullemoji;

        if (curSelected >= menuOptions.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = menuOptions.length - 1;
        menuStuff.forEach(function(spr:FlxText)
        {
            switch (spr.ID)
            {
                case 0:
                    spr.offset.y = 20;
                case 1:
                    spr.offset.y = -20;
                case 2:
                    spr.offset.y = -60;
            }

            spr.color = FlxColor.YELLOW;

            if (spr.ID  == curSelected)
            {
                spr.color = FlxColor.RED;
            }
        });
    }
}