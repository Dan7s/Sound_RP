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
				ReorderableListView(
					scrollDirection: Axis.vertical,
					children: [
						for (final track in tracks)
							Card(
								color: Colors.grey[800],
								child: ListTile(
									title: Text(track.name.toString(), style: TextStyle(color: Colors.white)),
									leading: isFirstTrack(track.id) ? Icon(Icons.play_circle_outline, color: Colors.green) :  Icon(Icons.drag_handle, color: Colors.green),
									trailing: IconButton(
										icon: Icon(Icons.delete, color: Colors.green),
										tooltip: 'Delete track',
										onPressed: () => {deleteTrack(track), setState(() {})},
									),								
								),
								key: ObjectKey(track.id),
							),
					],					
					onReorder: (int oldIndex, int newIndex) {
						setState(() {
							if (newIndex > oldIndex) {
								newIndex -= 1;
							}
							final Track track = tracks.removeAt(oldIndex);
							tracks.insert(newIndex, track);
						});
					},
				),
				floatingActionButton: FloatingActionButton(
					onPressed: () async {
						Track new_track = await addTrack(context, idCounter);
						if (new_track != null) {
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
	final String name;
	final String link;
	final int id;
	final int loop;

	Track(this.name, this.link, this.loop, this.id);
}

bool isFirstTrack(id) {
	if (get_next_track().id == id) {
		return true;
	} else {
		return false;
	}
}

Future deleteTrack(Track track) async { 		//track deleting
	tracks.remove(track);
}

Future<int> loopChange(BuildContext context, track) async {
	int loopValue = track.loop;
	
	final _formKey = GlobalKey<FormState>();
	
	return showDialog(
		context : context,
		builder: (BuilderContext context) {
			return SimpleDialog(
				backgroundColor: Colors.black,
				title: Text("Loop input", style: TextStyle(color: Colors.white)),
				children: [
					Center(
						child: Column(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Form(
									key: _formKey,
									child: Column(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,

										children: [
											TextFormField(
												decoration: const InputDecoration(
													filled: true,
													fillColor: Colors.grey,
													focusColor: Colors.green,
												),
												validator: (value) {
													if (value.isEmpty) {
														return 'Please enter track name';
													}
												},
												onSaved: (val) => loopValue = val,
												initialValue: loopValue,
											),
											Padding(
												padding: const EdgeInsets.symmetric(vertical: 16.0),
												child: RaisedButton(
													color: Colors.grey[700],
													onPressed: () {
														if (_formKey.currentState.validate()) {
															_formKey.currentState.save();
															
															Navigator.pop(context, val);
														}
														else {
															Navigator.pop(context, null);
														}											
													},
													child: Text("Add", style: TextStyle(color: Colors.white))
												),
											),
											
										],
									),
								),
							],
						),
					),
				],
			),
		}
	),
}

Future<Track> addTrack(BuildContext context, idCounter) async {		//adding tacks dialog
	String name;
	String link;
	String id;

	final _formKey = GlobalKey<FormState>();

	return showDialog (
		context: context,
		builder: (BuildContext context) {
			return SimpleDialog(
				backgroundColor: Colors.black,			
				title: Text("Add track", style: TextStyle(color: Colors.white)),
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
												onSaved: (val) => name = val,
											),
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
												onSaved: (val) => link = val,
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
															Track new_track = new Track(name, link, idCounter);
															Navigator.pop(context, new_track);
														}
														else {
															Navigator.pop(context, null);
														}											
													},
													child: Text("Add", style: TextStyle(color: Colors.white))
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

Track get_next_track() {			//func to geting first track`s link from queue by main.dart to play it
	return(tracks.first);
}
