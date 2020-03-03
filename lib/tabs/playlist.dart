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
									trailing: PopupMenuButton<int>(
										onSelected: (value) async{
											if (value == 1){ 		//delete button
												deleteTrack(track);  
											} else if (value == 2) {		//edit button
												Track new_track = Track(track.name, track.link, track.loop, track.id); 
												new_track = await editTrack(context, new_track);
												if (new_track.name != "" && new_track.link != "" && new_track != track) {
													int track_index = tracks.indexOf(track);
													deleteTrack(track);
													tracks.insert(track_index, new_track);
												};
											};
											setState((){});
										},
										offset: Offset(0, 100),
										color: Colors.grey[700],
										icon: Icon(Icons.more_vert, color: Colors.green),
										itemBuilder: (context) => [
											PopupMenuItem(
												value: 1,
												child: Row(
													children: <Widget>[
														Icon(Icons.delete, color: Colors.green),
														Text("Delete", style: TextStyle(color: Colors.white)),
													],
												),
											),
											PopupMenuItem(
												value: 2,
												child: Row(
													children: <Widget>[
														Icon(Icons.edit, color: Colors.green),
														Text("Edit", style: TextStyle(color: Colors.white)),
													],
												),
											),
										],								
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
						Track new_track = Track("", "", 1, idCounter); 
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
	final String name;
	final String link;
	final int loop;
	final int id;

	Track(this.name, this.link, this.loop, this.id);
}

bool isFirstTrack(id) {				//getting first track bool
	if (get_next_track().id == id) {
		return true;
	} else {
		return false;
	}
}

Future deleteTrack(Track track) async { 		//track deleting
	tracks.remove(track);
}

Future<Track> editTrack(BuildContext context, track) {		//editing tacks dialog
	String name = track.name;
	String link = track.link;
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
															Track new_track = new Track(name, link, 1, int.parse(id));
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

Track get_next_track() {			//func to geting first track`s link from queue by main.dart to play it
	return(tracks.first);
}
