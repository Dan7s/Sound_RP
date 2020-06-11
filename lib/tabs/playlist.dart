import 'package:flutter/material.dart';

class PlaylistTab extends StatefulWidget {
	@override
	PlaylistState createState() => PlaylistState();
}

List<Track> tracks = [];		//tracks list obj

class PlaylistState extends State<PlaylistTab> with AutomaticKeepAliveClientMixin<PlaylistTab>{ 	// main playlist tab obj 
	@override
	bool get wantKeepAlive => true;
	int idCounter = 0;

	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black,
			body:
				ReorderableListView(					//playlist
					scrollDirection: Axis.vertical,
					children: [
						for (final track in tracks)
							Card(				//playlist track tile
								color: Colors.grey[800],
								child: ListTile(
									title: Text(track.name.toString(), style: TextStyle(color: Colors.white)),
									leading: isFirstTrack(track.id) ? Icon(Icons.play_circle_outline, color: Colors.green) :  Icon(Icons.drag_handle, color: Colors.green),
									trailing: IconButton(						//Opening track menu
										icon: Icon(Icons.more_vert, color: Colors.green),
										tooltip: 'Track Menu',
										onPressed: () async{ 
											await trackMenu(context, track);	//setting state when needed
											setState(() {});
										},
									),
								),
								key: ObjectKey(track.id),
							),
					],					
					onReorder: (int oldIndex, int newIndex) {			//reordering list
						setState(() {
							if (newIndex > oldIndex) {
								newIndex -= 1;
							}
							final Track track = tracks.removeAt(oldIndex);
							tracks.insert(newIndex, track);
						});
					},
				),
				floatingActionButton: FloatingActionButton(			//adding action button
					onPressed: () async {
						Track new_track = Track("", "", 0, 0, idCounter); 
						new_track = await editTrack(context, new_track);
						if (new_track.name != "" && new_track.link != "" ) {
							tracks.add(new_track);
							idCounter += 1;
							setState(() {});
						};
					},
					child: Icon(Icons.add),
					tooltip: 'Add track',
					backgroundColor: Colors.green,
				),
		);
	}
}

class Track {			//track obj class
	String name;
	String link;
	int repeat;
	int startAt;
	int id;

	Track(this.name, this.link, this.repeat, this.startAt, this.id);
}

bool isFirstTrack(id) {				//getting first track bool
	if (tracks.first.id == id) {
		return true;
	} else {
		return false;
	}
}

void deleteTrack(Track track)  { 		//track deleting
	tracks.remove(track);
}

Future trackMenu(BuildContext context, track) {				//Track Menu, finally is working when playing
	return showDialog(
		context: context,
		builder: (BuildContext context) {
			return SimpleDialog(
				backgroundColor: Colors.grey[800],			
				title: Text(track.name, style: TextStyle(color: Colors.white)),
				children: [
					RaisedButton(
						color: Colors.grey[700],
						highlightColor: Colors.green,
						child: Text("Edit", style: TextStyle(color: Colors.white)),
						onPressed: () async{
							Track track_new = await editTrack(context, track);
							if (track_new != null) {
								track.name = track_new.name;
								track.link = track_new.link;
								track.repeat = track_new.repeat;
							}
						},
					),
					RaisedButton(
						color: Colors.grey[700],
						highlightColor: Colors.green,
						child: Text("Delete", style: TextStyle(color: Colors.white)),
						onPressed: () {
							deleteTrack(track);
							Navigator.pop(context);
						},
					),
					RaisedButton(
						color: Colors.grey[700],
						highlightColor: Colors.green,
						child: Text("Back", style: TextStyle(color: Colors.white)),
						onPressed: () {
							Navigator.pop(context);
						},
					),
				],
			);
		},	
	);
}

Future<int> chooseTime(BuildContext context, ms) {			//pupup for seek bar button 
	int startMS = ms;
	int startS = 0;
	int startM = 0;
	int startH = 0;
	if (ms >= 1000) {
		startS = ms~/1000;
		if (startS >= 60) {
			startM = startS ~/ 60;
			startS = startS - startM*60;
		}
		if (startM >= 60) {
			startH = startM ~/ 60;
			startM = startM - startH*60;
		}
	}
	
	final _formKey = GlobalKey<FormState>();
	
	return showDialog(
		context: context,
		builder: (BuildContext context) {
			return SimpleDialog(
				backgroundColor: Colors.grey[800],			
				title: Text("Time input", style: TextStyle(color: Colors.white)),
				children: [
					new Theme(
						data: Theme.of(context).copyWith(
							canvasColor: Color(0xFF616161),),
						child: Column(
							mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							mainAxisSize: MainAxisSize.max,
							children: [
								Row( 
									mainAxisAlignment: MainAxisAlignment.spaceAround,
									mainAxisSize: MainAxisSize.max,
									children: [
										Container(
											width: 63.0,
											child: DropdownButtonFormField<int>(
												style: TextStyle(color: Colors.white),
												items: List.generate(60, (index) {
													return DropdownMenuItem<int>(
														value: index,
														child: Text('$index'),
													);
												}),
												decoration: const InputDecoration(
													labelText: 'H',
													labelStyle: TextStyle(color: Colors.green),
													filled: true,
													fillColor: Color(0xFF616161),
													focusedBorder: const OutlineInputBorder(
													      borderSide: const BorderSide(color: Colors.green),
													),
												),
												validator: (value) {
													if (value == null) {
														return 'Please input start time';	
													}
												},
												value: startH,
												onChanged: (int value) { startH = value; },
											),
										),
										Text(":", style: TextStyle(color: Colors.white)),
										Container(
											width: 63.0,
											child: DropdownButtonFormField<int>(
												style: TextStyle(color: Colors.white),
												items: List.generate(60, (index) {
													return DropdownMenuItem<int>(
														value: index,
														child: Text('$index'),
													);
												}),
												decoration: const InputDecoration(
													labelText: 'M',
													labelStyle: TextStyle(color: Colors.green),
													filled: true,
													fillColor: Color(0xFF616161),
													focusedBorder: const OutlineInputBorder(
													      borderSide: const BorderSide(color: Colors.green),
													),
												),
												validator: (value) {
													if (value == null) {
														return 'Please input start time';	
													}
												},
												value: startM,
												onChanged: (int value) { startM = value; },
											),
										),
										Text(":", style: TextStyle(color: Colors.white)),
										Container(
											width: 63.0,
											child: DropdownButtonFormField<int>(
												style: TextStyle(color: Colors.white),
												items: List.generate(60, (index) {
													return DropdownMenuItem<int>(
														value: index,
														child: Text('$index'),
													);
												}),
												decoration: const InputDecoration(
													labelText: 'S',
													labelStyle: TextStyle(color: Colors.green),
													filled: true,
													fillColor: Color(0xFF616161),
												),
												validator: (value) {
													if (value == null) {
														return 'Please input start time';	
													}
												},
												value: startS,
												onChanged: (int value) { startS = value; },
											),
										),
									]
								),
								Text(""),
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceAround,
									mainAxisSize: MainAxisSize.max,
									children: [
										RaisedButton(
											color: Colors.grey[700],
											highlightColor: Colors.green,
											onPressed: () {
												Navigator.pop(context, null);
											},
											child: Text("Back", style: TextStyle(color: Colors.white))
										),
										RaisedButton(
											color: Colors.grey[700],
											highlightColor: Colors.green,
											onPressed: () {
													startM = startM + startH*60;
													startS = startS + startM*60;
													startMS = startS*1000;
													Navigator.pop(context, startMS);											
											},
											child: Text("Save", style: TextStyle(color: Colors.white))
										),
									],
								),
							],
						),
					),	
				],
			);	
		}
	);
}

Future<Track> editTrack(BuildContext context, track) {		//editing tacks dialog
	String name = track.name;
	String link = track.link;
	String repeat = track.repeat.toString();
	String id = track.id.toString();
	int startMS = track.startAt;
	int startS = 0;
	int startM = 0;
	int startH = 0;
	if (startMS >= 1000) {
		startS = startMS~/1000;
		if (startS >= 60) {
			startM = startS ~/ 60;
			startS = startS - startM*60;
		}
		if (startM >= 60) {
			startH = startM ~/ 60;
			startM = startM - startH*60;
		}
	}

	final _formKey = GlobalKey<FormState>();

	return showDialog(
		context: context,
		builder: (BuildContext context) {
			return SimpleDialog(
				backgroundColor: Colors.grey[800],			
				title: Text("Edit track", style: TextStyle(color: Colors.white)),
				children: [
					Form(
						key: _formKey,
						child: new Theme(
							data: Theme.of(context).copyWith(
								canvasColor: Color(0xFF616161),),
							child: Column(
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
								mainAxisSize: MainAxisSize.max,
								children: [
									TextFormField(
										style: TextStyle(color: Colors.white),
										decoration: const InputDecoration(
											labelText: 'Name',
											labelStyle: TextStyle(color: Colors.green),
											filled: true,
											fillColor: Color(0xFF616161),
											focusedBorder: const OutlineInputBorder(
											      borderSide: const BorderSide(color: Colors.green),
											    ),
										),
										validator: (value) {
											if (value.isEmpty) {
												return 'Please enter track name';
											}
										},
										initialValue: name,
										onSaved: (val) => name = val,
									),
									Text(""),
									TextFormField(
										style: TextStyle(color: Colors.white),
										keyboardType: TextInputType.url,
										decoration: const InputDecoration(
											labelText: 'Link',
											labelStyle: TextStyle(color: Colors.green),
											filled: true,
											fillColor: Color(0xFF616161),
											focusedBorder: const OutlineInputBorder(
											      borderSide: const BorderSide(color: Colors.green),
											    ),
										),
										validator: (value) {
											if (value.isEmpty) {
												return 'Please enter link';
											}
										},
										initialValue: link,
										onSaved: (val) => link = val,
									),
									Text(""),
									TextFormField(
										style: TextStyle(color: Colors.white),
										keyboardType: TextInputType.number,
										decoration: const InputDecoration(
											labelText: 'Repeat',
											labelStyle: TextStyle(color: Colors.green),
											filled: true,
											fillColor: Color(0xFF616161),
											focusedBorder: const OutlineInputBorder(
											      borderSide: const BorderSide(color: Colors.green),
											    ),
										),
										validator: (value) {
											if (value.isEmpty) {
												return 'Please input repeat count';
											}
										},
										initialValue: repeat,
										onSaved: (val) => repeat = val,
									),
									Text(""),
									Row( 
										mainAxisAlignment: MainAxisAlignment.spaceAround,
										mainAxisSize: MainAxisSize.max,
										children: [
											Container(
												width: 63.0,
												child: DropdownButtonFormField<int>(
													style: TextStyle(color: Colors.white),
													items: List.generate(60, (index) {
														return DropdownMenuItem<int>(
															value: index,
															child: Text('$index'),
														);
													}),
													decoration: const InputDecoration(
														labelText: 'H',
														labelStyle: TextStyle(color: Colors.green),
														filled: true,
														fillColor: Color(0xFF616161),
														focusedBorder: const OutlineInputBorder(
														      borderSide: const BorderSide(color: Colors.green),
														),
													),
													validator: (value) {
														if (value == null) {
															return 'Please input start time';	
														}
													},
													value: startH,
													onChanged: (int value) { startH = value; },
												),
											),
											Text(":", style: TextStyle(color: Colors.white)),
											Container(
												width: 63.0,
												child: DropdownButtonFormField<int>(
													style: TextStyle(color: Colors.white),
													items: List.generate(60, (index) {
														return DropdownMenuItem<int>(
															value: index,
															child: Text('$index'),
														);
													}),
													decoration: const InputDecoration(
														labelText: 'M',
														labelStyle: TextStyle(color: Colors.green),
														filled: true,
														fillColor: Color(0xFF616161),
														focusedBorder: const OutlineInputBorder(
														      borderSide: const BorderSide(color: Colors.green),
														),
													),
													validator: (value) {
														if (value == null) {
															return 'Please input start time';	
														}
													},
													value: startM,
													onChanged: (int value) { startM = value; },
												),
											),
											Text(":", style: TextStyle(color: Colors.white)),
											Container(
												width: 63.0,
												child: DropdownButtonFormField<int>(
													style: TextStyle(color: Colors.white),
													items: List.generate(60, (index) {
														return DropdownMenuItem<int>(
															value: index,
															child: Text('$index'),
														);
													}),
													decoration: const InputDecoration(
														labelText: 'S',
														labelStyle: TextStyle(color: Colors.green),
														filled: true,
														fillColor: Color(0xFF616161),
													),
													validator: (value) {
														if (value == null) {
															return 'Please input start time';	
														}
													},
													value: startS,
													onChanged: (int value) { startS = value; },
												),
											),
										]
									),
									Text(""),
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceAround,
										mainAxisSize: MainAxisSize.max,
										children: [
											RaisedButton(
												color: Colors.grey[700],
												highlightColor: Colors.green,
												onPressed: () {
													Navigator.pop(context, null);
												},
												child: Text("Back", style: TextStyle(color: Colors.white))
											),
											RaisedButton(
												color: Colors.grey[700],
												highlightColor: Colors.green,
												onPressed: () {
													if (_formKey.currentState.validate()) {
														_formKey.currentState.save();
														if (link.contains('=')) {
															link = link.split('=')[1];
														}
														if (link.contains('&')) {
															link = link.split('&')[0];		
														}
														startM = startM + startH*60;
														startS = startS + startM*60;
														startMS = startS*1000;
														Track new_track = new Track(name, link, int.parse(repeat), startMS, int.parse(id));
														Navigator.pop(context, new_track);
													}											
												},
												child: Text("Save", style: TextStyle(color: Colors.white))
											),
										],
									),
								],
							),
						),
					),	
				],
			);
		},	
	);
	
}
