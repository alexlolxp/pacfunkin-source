package;

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

class PacMainMenu extends MusicBeatState
{
    public static var modVer:String = '1.0';
    public static var curSelected:Int = 0;
    var credNames:FlxText;

    var menuStuff:FlxTypedGroup<FlxText>;
    private var camGame:FlxCamera;

    var menuOptions:Array<String> = ['play!', 'freeplay', 'options'];

    override function create() 
    {
        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Main Menu", null);
		#end

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
		add(bg);

		var border:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('border'));
		border.scrollFactor.set();
		border.updateHitbox();
		border.screenCenter();
		border.antialiasing = ClientPrefs.globalAntialiasing;
		add(border);

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
            });

        var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, modVer, 12);
        versionShit.scrollFactor.set();
        versionShit.setFormat("Emulogic", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(versionShit);

        super.create();
    }
     
    var selectedThing:Bool = false;

    override function update(elapsed:Float)
    {
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
            });
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