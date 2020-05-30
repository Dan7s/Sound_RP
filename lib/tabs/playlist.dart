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
											bool update = await trackMenu(context, track);	//setting state when needed
											if (update) {
												setState(() {});
											}
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
						Track new_track = Track("", "", 0, idCounter); 
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
	int loop;
	int id;

	Track(this.name, this.link, this.loop, this.id);
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

Future<bool> trackMenu(BuildContext context, track) {				//Track Menu, finally is working when playing
	return showDialog(
		context: context,
		builder: (BuildContext context) {
			return SimpleDialog(
				backgroundColor: Colors.grey[800],			
				title: Text(track.name, style: TextStyle(color: Colors.white)),
				children: [
					RaisedButton(
						color: Colors.grey[700],
						child: Text("Edit", style: TextStyle(color: Colors.white)),
						onPressed: () async{
							Track track_new = await editTrack(context, track);
							track.name = track_new.name;
							track.link = track_new.link;
							track.loop = track_new.loop;
							Navigator.pop(context, true);
						},
					),
					RaisedButton(
						color: Colors.grey[700],
						child: Text("Delete", style: TextStyle(color: Colors.white)),
						onPressed: () {
							deleteTrack(track);
							Navigator.pop(context, true);
						},
					),
					RaisedButton(
						color: Colors.grey[700],
						child: Text("Back", style: TextStyle(color: Colors.white)),
						onPressed: () {
							Navigator.pop(context, false);
						},
					),
				],
			);
		},	
	);
}

Future<Track> editTrack(BuildContext context, track) {		//editing tacks dialog
	String name = track.name;
	String link = track.link;
	String loop = track.loop.toString();
	String id = track.id.toString();

	final _formKey = GlobalKey<FormState>();

	return showDialog (
		context: context,
		builder: (BuildContext context) {
			return SimpleDialog(
				backgroundColor: Colors.grey[800],			
				title: Text("Edit track", style: TextStyle(color: Colors.white)),
				children: [
					Center(
						child: Column(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Form(
									key: _formKey,
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.center,
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [ 
											TextFormField(
												decoration: const InputDecoration(
													hintText: 'Enter track name',
													filled: true,
													fillColor: Colors.grey,
													focusColor: Colors.green,
												),
												validator: (value) {
													if (value.isEmpty) {
														return 'Please enter track name';
													}
												},
												initialValue: name,
												onSaved: (val) => name = val,
											),
											Text("", style: TextStyle(color: Colors.white)),
											TextFormField(
												decoration: const InputDecoration(
													hintText: 'Enter track link',
													filled: true,
													fillColor: Colors.grey,
													focusColor: Colors.green,
												),
												validator: (value) {
													if (value.isEmpty) {
														return 'Please enter link';
													}
												},
												initialValue: link,
												onSaved: (val) => link = val,
											),
											Text("Loop count:", style: TextStyle(color: Colors.white)),
											TextFormField(
												decoration: const InputDecoration(
													hintText: 'Enter loop number, -1 = loop to skip',
													filled: true,
													fillColor: Colors.grey,
													focusColor: Colors.green,
												),
												validator: (value) {
													if (value.isEmpty) {
														return 'Please loops count';
													}
												},
												initialValue: loop,
												onSaved: (val) => loop = val,
											),
											Padding(
												padding: const EdgeInsets.symmetric(vertical: 16.0),
												child: RaisedButton(
													color: Colors.grey[700],
													onPressed: () {
														if (_formKey.currentState.validate()) {
															_formKey.currentState.save();
															if (link.contains('=')) {
																link = link.split('=')[1];
															}
															if (link.contains('&')) {
																link = link.split('&')[0];		
															}
															Track new_track = new Track(name, link, int.parse(loop), int.parse(id));
															Navigator.pop(context, new_track);
														}
														else {
															Navigator.pop(context, track);
														}											
													},
													child: Text("Save", style: TextStyle(color: Colors.white))
												),
											),
										],
									),
								),
							],
						),
					),	
				],
			);
		},	
	);
	
}
