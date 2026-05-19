package funkin.states;

import sys.thread.Mutex;
import sys.thread.Thread;

import funkin.audio.SyncedFlxSoundGroup;

import haxe.Json;

import funkin.objects.Character;

import openfl.utils.AssetType;
import openfl.utils.Assets;

import funkin.states.substates.PauseSubState;

class LoadingState extends MusicBeatState
{
	var leaveState:Bool;
	
	var threadActive:Bool;
	
	override function create()
	{
		super.create();
		var mutex = new Mutex();
		Thread.create(function() {
			mutex.acquire();
			threadActive = true;
			trace('loading startedf');
			loadSongAudio();
			trace('loading audio');
			loadCharacterSprite(PlayState.SONG.player1);
			loadCharacterSprite(PlayState.SONG.player2);
			loadCharacterSprite(PlayState.SONG.gfVersion);
			trace('loaded sprites');
			loadSounds();
			threadActive = false;
			mutex.release();
		});
	}
	
	function loadSongAudio()
	{
		if (ClientPrefs.streamedMusic) return;
		var audio:PlayableSong = new PlayableSong();
		audio.populate(PlayState.SONG);
		trace(PlayState.SONG.song);
		audio.hit();
		add(audio);
	}
	
	function loadCharacterSprite(_char:String)
	{
		var characterList:Array<String> = [];
		var path:String = null;
		var mods:Array<{folder:String, enabled:Bool}> = Mods.getListAsArray();
		for (mod in mods)
		{
			var dir = Paths.getPath('data/characters/', mod.folder, true);
			if (FileSystem.exists(dir + _char + '.json'))
			{
				path = dir + _char + '.json';
				trace(path);
				trace('found $_char');
				break;
			}
		}
		
		/*
				if (file.endsWith('.json') || file.endsWith('.xml'))
			{
				var charToCheck:String = file.withoutDirectory().withoutExtension();
				trace(charToCheck);
				if (charToCheck == _char)
				{
					path = dir + _char + '.jsonj';
					trace('found file ' + path);
					break;
				}
			}
		 */
		if (path == null) return;
		var character:Dynamic = Json.parse(FileSystem.exists(path) ? File.getContent(path) : Assets.getText(path));
		trace(character.image);
		Paths.image(character.image);
	}
	
	function loadSounds()
	{
		if (ClientPrefs.hitsoundVolume > 0) Paths.sound('hitsound');
		Paths.sound('missnote1');
		Paths.sound('missnote2');
		Paths.sound('missnote3');
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (!threadActive && !leaveState)
		{
			leaveState = true;
			FlxG.switchState(PlayState.new);
		}
	}
}
