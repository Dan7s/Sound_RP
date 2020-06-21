import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';

import 'package:sound_rp/tabs/playlist.dart';
import 'package:sound_rp/tabs/noise.dart';
import 'package:sound_rp/tabs/settings.dart';

enum PlayerState { stopped, playing, paused } 

void main() {
	runApp(MaterialApp(
      		title: 'SoundRP',
      		theme: ThemeData(
        		accentColor: Colors.green,
     	 	),
      		home: Home(),
    	));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{
  TabController tab_controller;
  AudioPlayer audioPlayer = new AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration();
  Duration _position = Duration();
  int last_seek = 0;
  String sharedLink = "";

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration.toString().split('.').first;
  get _positionText => _position.toString().split('.').first;
  get _repeatCount => tracks.first.repeat.toString();
  get _willRepeat => tracks.isNotEmpty ? tracks.first.repeat != 0 : false;

  void initState() {
		super.initState();
		tab_controller = TabController(length: 3, vsync: this);
		_initAudioPlayer();
  }

  void dispose() {
		audioPlayer.stop();
		tab_controller.dispose();
		super.dispose();
  }

  void _initAudioPlayer() {						//initing audio player, temporary implementation. AdvancedAudioPlayer will be needed
	audioPlayer.onDurationChanged.listen((duration) {	//getting and setting Duration of playing instance
		setState(() => _duration = duration);
	});
	audioPlayer.onAudioPositionChanged.listen((Duration p) => setState(() {		//getting and setting actual position of playing instance
		_position = p;
	}));	
	audioPlayer.onPlayerCompletion.listen((event) {		//end of track event
		_onComplete();
		setState(() {
			_position = Duration();
			_duration = Duration();
		});
	    });
  }
	
  void _onComplete() {		//skiping to next when track completed
		skip(1);
  }

  Future play() async {						//play func, getting next track from playlist tab and play it
		if (tracks.isNotEmpty) {
			final result = await audioPlayer.play("https://invidio.us/latest_version?id=" + tracks.first.link + "&itag=251");
			if (tracks.first.startAt != 0) {
				await seek(tracks.first.startAt);
			}
			if (result == 1 ) {
				setState(() {
					_playerState = PlayerState.playing;
				});
			}
		}
  }
  
  Future resume() async {
  	final result = await audioPlayer.resume();
  	if (result == 1) {
		setState(() {
			_playerState = PlayerState.playing;
		});	
	}
  }

  Future pause() async {
	final result = await audioPlayer.pause();
	if (result == 1) {
		setState(() {
			_playerState = PlayerState.paused;
		});	
	}
  }

  Future stop() async {	
	final result = await audioPlayer.stop();
	if (result == 1) {
		setState(() {
			_playerState = PlayerState.stopped;
			_position = Duration();
			_duration = Duration();
		});	
	}
  }
 
  Future skip(snum) async {					//skip function with repeat managing
	if (tracks.isNotEmpty) {
		if (tracks.first.repeat == 0) {
			stop();
			deleteTrack(tracks.first);
			play();
		} else {
			tracks.first.repeat = tracks.first.repeat - snum;
			play();
		}
	} 
  }
  
  Future seek(dur) async {
  	final result = await audioPlayer.seek(Duration(milliseconds: dur));
  	last_seek = dur;
  }
  
  Future seekButton() async {
		if (tracks.isNotEmpty) {
			var seekTo = await chooseTime(context, _position.inMilliseconds);
			if (seekTo != null) {
				seek(seekTo);
			}
		}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
	backgroundColor: Colors.grey[700],
	title: Text('SoundRP', style: TextStyle( color: Colors.white)),
	centerTitle: true,
	bottom: 
		PreferredSize(
			preferredSize: const Size.fromHeight(48.0),
			child: Column(
				children: <Widget>[ 
					Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							IconButton(
								icon: Icon(Icons.find_replace, size: 28.0, color: Colors.green),
								tooltip: 'Seek',
								onPressed: () => seekButton(),
							),
							IconButton(
								icon: Icon(Icons.stop, size: 28.0, color: Colors.green),
								tooltip: 'Stop',
								onPressed: () => stop(),
							),
							IconButton(
								icon: _isPlaying ? Icon(Icons.pause, size: 28.0, color: Colors.green) : Icon(Icons.play_arrow, size: 28.0, color: Colors.green),
								tooltip: _isPlaying ? 'Pause' : 'Play/Resume',
								onPressed: _isPlaying ? () => pause() : () => play(),
							),
							IconButton(
								icon: Icon(Icons.skip_next, size: 28.0, color: Colors.green),
								tooltip: 'Skip',
								onPressed: () => skip(1),
							),
							IconButton(
								icon: Icon(Icons.skip_next, size: 28.0, color: Colors.green),
								tooltip: 'Force skip',
								onPressed: () {
									skip(tracks.first.repeat);
								}
							),
						],
					),
					Row( 
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Text(tracks.isNotEmpty ?  "$_positionText" + "/" + "$_durationText " : "", style: TextStyle(color: Colors.white)),
							_willRepeat ? Icon(Icons.repeat, size: 28.0, color: Colors.green) : Container(),
							_willRepeat ? Text("$_repeatCount", style: TextStyle(color: Colors.white)) : Container(),
						],
					),
					LinearProgressIndicator(
						backgroundColor: Colors.grey[700],
						valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
						value: (_position.inMilliseconds < _duration.inMilliseconds && _position.inMilliseconds > 0 && last_seek != _position.inMilliseconds)
							? _position.inMilliseconds / _duration.inMilliseconds : 
							(_playerState == PlayerState.playing) ? null : 0.0,
					),
				],
			),
		),
      ),


      body: TabBarView(
	children: <Widget>[PlaylistTab(), NoiseTab(), SettingsTab()],
	controller: tab_controller,
      ),

      bottomNavigationBar: Material(
	color: Colors.grey[700],
	child: TabBar(
		tabs: <Tab>[
			Tab(
				text: 'Playlist',
				icon: Icon(
					Icons.library_music,
					color: Theme.of(context).accentColor,
				),
			),
			Tab(
				text: 'Instant Noise',
				icon: Icon(
					Icons.music_note,
					color: Theme.of(context).accentColor,
				),
			),
			Tab(
				text: 'Settings',
				icon: Icon(
					Icons.settings,
					color: Theme.of(context).accentColor,
				),
			),
		],
		controller: tab_controller,
		labelStyle: TextStyle(fontSize: 16, color: Colors.white),
		unselectedLabelStyle: TextStyle(fontSize: 13, color: Colors.grey),
	),
     ),
    );
  }
}
