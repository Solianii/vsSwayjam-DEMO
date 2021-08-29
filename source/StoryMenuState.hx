package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var weekData:Array<Dynamic> = [
		['Tutorial'],
		['Goals']
	];
	var curDifficulty:Int = 0;

	public static var weekUnlocked:Array<Bool> = [true, true];

	var weekCharacters:Array<Dynamic> = [
		['', 'bf', 'gf'],
		['dad', 'bf', 'gf']
	];

	var weekNames:Array<String> = [
		"How to Funk",
		"Streaming: Funky Friday"
	];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekGraphics:FlxTypedGroup<FlxSprite>; // all weeks
	var weekHover:FlxSprite; // highlighted week
	
	var weekThing:FlxSprite;
	var tex:FlxAtlasFrames;
	var weekNameThingy:String;
	var lastSelectedWeek:Int;
	var xPos:Float = 0;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	
	var bgDifficulty:FlxSprite;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, .5);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, .25);
		
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(0, 0, 0, "WEEK SCORE:", 45);
		scoreText.font = Paths.font("Mousse-Regular.otf");
		scoreText.alignment = LEFT;
		scoreText.y = FlxG.height-scoreText.height;
		scoreText.screenCenter(X);
		scoreText.x -= 300;

		txtWeekTitle = new FlxText(0, 400, 0, "", 36);
		txtWeekTitle.setFormat(Paths.font("Mousse-Regular.otf"), 36, FlxColor.WHITE, CENTER);
		txtWeekTitle.alpha = 0.8;
		txtWeekTitle.screenCenter(X);
		txtWeekTitle.x -= 400;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		//var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var ui_tex = Paths.getSparrowAtlas('sm_UI');
		bgDifficulty = new FlxSprite().loadGraphic(Paths.image('grad_difficulty'));
		bgDifficulty.setGraphicSize(FlxG.width, FlxG.height);
		bgDifficulty.updateHitbox();
		bgDifficulty.screenCenter();
		add(bgDifficulty);
		bgDifficulty.color = 0xFF00ff00;

		//grpWeekGraphicselects = new FlxTypedGroup<FlxSprite>();
		//add(grpWeekGraphicselects);
		grpWeekGraphics = new FlxTypedGroup<FlxSprite>();
		add(grpWeekGraphics);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");
		
		tex = Paths.getSparrowAtlas('sm_UI_weeks');

		for (i in 0...weekData.length)
		{
			var weekGraphic:FlxSprite = new FlxSprite();
			weekGraphic.frames = tex;
			weekGraphic.animation.addByPrefix("idle", "week" + Std.string(i) + " idle");
			weekGraphic.animation.addByPrefix("select", "week" + Std.string(i) + " select");
			weekGraphic.ID = i;
			weekGraphic.antialiasing = true;
			weekGraphic.alpha = 0;
			weekGraphic.animation.play("idle");
			weekGraphic.updateHitbox();
			weekGraphic.x = 0 - (FlxG.width/2);
			grpWeekGraphics.add(weekGraphic);
		}
		
		grpWeekGraphics.members[0].y = 250;
		grpWeekGraphics.members[1].y = 100;
		
		FlxTween.tween(grpWeekGraphics.members[0], {x: 107, alpha: 1}, .5,{ease: FlxEase.expoInOut});
		FlxTween.tween(grpWeekGraphics.members[1], {x: 161, alpha: .15}, .5,{ease: FlxEase.expoInOut});
		
		trace("Line 96");

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		sprDifficulty = new FlxSprite(0,0);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		sprDifficulty.alpha = 0;
		
		sprDifficulty.updateHitbox();
		sprDifficulty.screenCenter(X);
		sprDifficulty.x -= 300;

		difficultySelectors.add(sprDifficulty);

		leftArrow = new FlxSprite(0, FlxG.height);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		
		leftArrow.alpha = 0;
		leftArrow.updateHitbox();
		//leftArrow.y = scoreText.y - leftArrow.height-25;
		leftArrow.x = sprDifficulty.x - leftArrow.width - 50;
		
		difficultySelectors.add(leftArrow);
		sprDifficulty.y = scoreText.y - leftArrow.height-25;

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.alpha = 0;
		rightArrow.updateHitbox();
		difficultySelectors.add(rightArrow);
		
		
		FlxTween.tween(leftArrow, {y: scoreText.y - leftArrow.height-25, alpha: 1}, .5,{ease: FlxEase.expoInOut});
		FlxTween.tween(rightArrow, {y: scoreText.y - leftArrow.height-25, alpha: 1}, .5,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
				{ 
					sprDifficulty.alpha = 1;
					changeDifficulty();
				}});
		
		var tracks:FlxSprite = new FlxSprite(0,0);
		tracks.frames = ui_tex;
		tracks.animation.addByPrefix('tracks', 'tracks');
		tracks.animation.play('tracks');
		tracks.antialiasing = true;
		tracks.setGraphicSize(Std.int(tracks.width*.5));
		tracks.updateHitbox();
		tracks.screenCenter(X);
		tracks.x -= 300;
		tracks.y = 450;
		tracks.alpha = .5;
		add(tracks);

		trace("Line 150");

		txtTracklist = new FlxText(0, 0, 0, "", 80);
		txtTracklist.alignment = RIGHT;
		txtTracklist.font = Paths.font("LEMONMILK-Regular.otf");
		txtTracklist.color = FlxColor.WHITE;
		txtTracklist.x = FlxG.width-txtTracklist.width-75;
		txtTracklist.screenCenter(Y);
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		trace("Line 165");

		super.create();
	}

	override function update(elapsed:Float)
	{
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE: " + lerpScore;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.screenCenter(X);
		txtWeekTitle.x -= 300;

		difficultySelectors.visible = weekUnlocked[curWeek];
		
		//grpLocks.forEach(function(lock:FlxSprite)
		//{
		//	lock.y = (grpWeekGraphics.members[lock.ID].height + 100) * grpWeekGraphics.members[lock.ID].ID;
		//});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}
	
	function cancelDumbTweens()
	{
		grpWeekGraphics.forEach(function(item:FlxSprite)
						{
							//cancelTweensOf(item);
						});
		//cancelTweensOf(leftArrow);
		//cancelTweensOf(rightArrow);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	//var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			
			grpWeekGraphics.members[curWeek].animation.play("select");
			
			FlxTween.tween(leftArrow, {alpha: 0}, .5,{ease: FlxEase.expoInOut});
			FlxTween.tween(rightArrow, {alpha: 0}, .5,{ease: FlxEase.expoInOut});
			FlxTween.tween((curWeek == 0 ? grpWeekGraphics.members[1]:grpWeekGraphics.members[0]), {alpha: 0}, .5,{ease: FlxEase.expoInOut});
			
			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(StringTools.replace(PlayState.storyPlaylist[0]," ", "-").toLowerCase() + diffic, StringTools.replace(PlayState.storyPlaylist[0]," ", "-").toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				//cancelDumbTweens();
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				//sprDifficulty.offset.x = 20;
				bgDifficulty.color = 0xFF00ff00;
			case 1:
				sprDifficulty.animation.play('normal');
				//sprDifficulty.offset.x = 70;
				bgDifficulty.color = 0xFFffff00;
			case 2:
				sprDifficulty.animation.play('hard');
				//sprDifficulty.offset.x = 20;
				bgDifficulty.color = 0xFFff0000;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y + 50;
		leftArrow.updateHitbox();
		sprDifficulty.updateHitbox();
		rightArrow.updateHitbox();
		
		sprDifficulty.screenCenter(X);
		sprDifficulty.x -= 300;
		leftArrow.x = sprDifficulty.x - leftArrow.width - 50;
		rightArrow.x = sprDifficulty.x + sprDifficulty.width + 50;
		
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 10, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = 1;

		for (item in grpWeekGraphics)
		{
			if (item.ID == curWeek)
			{
				FlxTween.tween(item, {y: 250, alpha: 1}, .2,{ease: FlxEase.expoInOut});
				//item.y = 250;
				item.alpha = 1;
			}
			else
			{
				FlxTween.tween(item, {y: 100, alpha: .15}, .2,{ease: FlxEase.expoInOut});
				//item.y = 100;
				item.alpha = .15;
			}
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		txtTracklist.text = "";
		var stringThing:Array<String> = weekData[curWeek];

		for (i in stringThing)
			txtTracklist.text += i + "\n";

		txtTracklist.text = txtTracklist.text.toUpperCase();
		
		txtTracklist.x = FlxG.width-txtTracklist.width-75;
		
		txtTracklist.screenCenter(Y);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
