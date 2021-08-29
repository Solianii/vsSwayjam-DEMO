package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class CreditMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	var counter:Int = 0;
	
	var bg:FlxSprite;
	var icon:FlxSprite;
	var credA:FlxText;
	var credB:FlxText;
	
	var grpBG:FlxTypedGroup<FlxSprite>;
	var grpIcon:FlxTypedGroup<FlxSprite>;
	var grpCredA:FlxTypedGroup<FlxText>;
	var grpCredB:FlxTypedGroup<FlxText>;
	
	var first:Bool = true;
	var placeholder:Bool = true;
	
	override function create()
	{
		grpBG = new FlxTypedGroup<FlxSprite>();
		grpIcon = new FlxTypedGroup<FlxSprite>();
		grpCredA = new FlxTypedGroup<FlxText>();
		grpCredB = new FlxTypedGroup<FlxText>();
		add(grpBG);
		add(grpIcon);
		add(grpCredA);
		add(grpCredB);
		for (i in 0...7)
		{
			bg = new FlxSprite(0,0).loadGraphic(Paths.image('credits/bg'+i));
			bg.screenCenter();
			bg.antialiasing = true;
			bg.ID = i;
			bg.alpha = 0;
			grpBG.add(bg);
			
			icon = new FlxSprite(0,0);
			icon.frames = Paths.getSparrowAtlas('credits/icons');
			icon.ID = i;
			icon.animation.addByPrefix('icon', Std.string(i));
			icon.animation.play('icon');
			icon.updateHitbox();
			icon.setGraphicSize(Std.int(icon.width*1.5));
			icon.updateHitbox();
			icon.y = FlxG.height-icon.height-100;
			icon.alpha = 0;
			grpIcon.add(icon);
			
			credA = new FlxText(50, 50, 0, "", 100);
			credA.ID = i;
			credA.font = Paths.font("FE-FONT.TTF");
			credA.bold = true;
			grpCredA.add(credA);
			
			credB = new FlxText(50, 200, 0, "", 50);
			credB.ID = i;
			credB.font = Paths.font("bahnschrift.ttf");
			grpCredB.add(credB);
			
			switch (i)
			{
				case 0:
					credA.text = "Swayjam";
					credB.text = 'Director\ntwitch.tv/swayjam\n\n\n\n\n\n"seriously, don\'t put me in the credits sol"';
				case 1:
					credA.text = "Soliani";
					credB.text = "Programmer/Animator\n\n\n\n\n\n\nlmao too bad";
				case 2:
					credA.text = "NameMeRose";
					credB.text = 'Music\nsoundcloud.com/this-is-rose\n\n\n\n\n\n"im swag, follow my soundcloud thanks <3"';
				case 3:
					credA.text = "MrWaffles";
					credB.text = "Charting";
				case 4:
					credA.text = "Rex";
					credB.text = "Miscellaneous Artist -- chair\n@RexDoesStuffEN\n\n\n\n\n\nassets/images/characters/chairex.xml";
				case 5:
					credA.text = "Shelly";
					credB.text = 'Background Artist\nFurAffinity @mooilo\n\n\n\n\n\n"i have no idea u can just put anything for mine"';
				case 6:
					credA.text = "Maluwukys";
					credB.text = "Sprite Concepts & Assets\n\n\n\n\n\n\nsus";
					
			}
		}
		
		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);
		changeItem();
		super.create();
	}
	
	override function beatHit()
	{
		if (curBeat % 4 == 0)
			changeItem(1);
	}

	override function update(elapsed:Float)
	{
		if (placeholder)
		{
			placeholder = false;
			new FlxTimer().start(5, function(tmr:FlxTimer)
									{
										changeItem(1);
										placeholder = true;
									});
		}
		
		if (controls.BACK || controls.ACCEPT)
		{
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
	
	function changeItem(huh:Int = 0)
	{
		var lastSelected = curSelected;
		curSelected += huh;

		if (curSelected >= grpBG.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = grpBG.length - 1;
		
		for (i in 0...grpBG.length)
		{
			if (i == curSelected)
			{
				FlxTween.tween(grpBG.members[i], {alpha: 1, x:0}, 1.5, {ease: FlxEase.expoInOut});
				FlxTween.tween(grpCredA.members[i], {alpha: 1, x:50}, 1.5, {ease: FlxEase.expoInOut});
				FlxTween.tween(grpCredB.members[i], {alpha: 1, x:50}, 1.5, {ease: FlxEase.expoInOut});
				FlxTween.tween(grpIcon.members[i], {alpha: 1, x:FlxG.width-grpIcon.members[i].width-50}, 1.5, {ease: FlxEase.expoInOut});
			}
			else if (i == lastSelected)
			{
				FlxTween.tween(grpBG.members[i], {alpha: 0, x:-FlxG.width}, 1.5, {ease: FlxEase.expoInOut});
				FlxTween.tween(grpCredA.members[i], {alpha: 0, x:-1800}, 1.5, {ease: FlxEase.expoInOut});
				FlxTween.tween(grpCredB.members[i], {alpha: 0, x:-1500}, 1.5, {ease: FlxEase.expoInOut});
				FlxTween.tween(grpIcon.members[i], {alpha: 0, x:-1400}, 1.5, {ease: FlxEase.expoInOut});
			}
			else
			{
				grpBG.members[i].alpha = 0;
				grpBG.members[i].x = FlxG.width;
				grpCredA.members[i].alpha = 0;
				grpCredA.members[i].x = 1800;
				grpCredB.members[i].alpha = 0;
				grpCredB.members[i].x = 1500;
				grpIcon.members[i].alpha = 0;
				grpIcon.members[i].x = 1400;
			}
		
		}
	}
}
