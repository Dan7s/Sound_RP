import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration.toString().split('.').first;
  get _positionText => _position.toString().split('.').first;

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

  void _initAudioPlayer() {
	audioPlayer.onDurationChanged.listen((duration) {
		setState(() => _duration = duration);
	});
	audioPlayer.onAudioPositionChanged.listen((Duration p) => setState(() {
		_position = p;
	}));
        audioPlayer.onPlayerCompletion.listen((event) {
		_onComplete();
		setState(() {
			_position = Duration();
			_duration = Duration();
		});
	    });
  }
	
  void _onComplete() {
	skip();
  }

  Future play() async {
	final result = await audioPlayer.play("https://invidio.us/latest_version?id="+get_next_track().link+"&itag=251");
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
 
  Future skip() async {
	stop();
	if (tracks.isNotEmpty) {
		deleteTrack(tracks.first);
		play();
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
								tooltip: 'Next track',
								onPressed: () => skip(),
							),
						],
					),
					Text("$_positionText" + "/" + "$_durationText", style: TextStyle(color: Colors.white)),
					LinearProgressIndicator(
						backgroundColor: Colors.grey[700],
						valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
						value: (_position.inMilliseconds < _duration.inMilliseconds &&
							_position.inMilliseconds > 0)
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
