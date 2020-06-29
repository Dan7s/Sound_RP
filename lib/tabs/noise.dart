import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class NoiseTab extends StatefulWidget {
	@override
	NoiseState createState() => NoiseState();
}

List<Noise> noises = [];
int idCounterN = 0;

class NoiseState extends State<NoiseTab> with AutomaticKeepAliveClientMixin<NoiseTab> {
	// main noise tab obj
	@override
	bool get wantKeepAlive => true;

	void initState() {
		_initDownloaderAndPath();
		super.initState();
	}

	void _initDownloaderAndPath() async {
		WidgetsFlutterBinding.ensureInitialized();
		await FlutterDownloader.initialize(
				debug: true // optional: set false to disable printing logs to console
		);
	}

	Widget build(BuildContext context){
		return Scaffold(
				backgroundColor: Colors.black,
				body: GridView.builder(
						itemCount: noises.length,
						gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 3,),
						itemBuilder: (context, index) {
								return Card(
									color: Colors.grey[800],
									child: Center( child: Text( noises[index].title, style: TextStyle(color: Colors.white)),),
								);
						},
				),
				floatingActionButton: FloatingActionButton(			//adding action button
					onPressed: () async {
						addMenu(context);
						setState(() {});
					},
					child: Icon(Icons.more_vert),
					tooltip: 'Add noise',
					backgroundColor: Colors.green,
				),
		);
	}
}

class Noise {
	String title;
	String path;
	int id;

	Noise(this.title, this.path, this.id);
}

void addNoise() {
	noises.add(new Noise("Test " + idCounterN.toString(), "test", idCounterN));
	idCounterN += 1;
}

Future addMenu(BuildContext context) {
	return showDialog(
		context: context,
		builder: (BuildContext context) {
			return SimpleDialog(
				backgroundColor: Colors.grey[800],
				title: Text("Add noise", style: TextStyle(color: Colors.white)),
				children: [
					RaisedButton(
						color: Colors.grey[700],
						highlightColor: Colors.green,
						child: Text("Download form link", style: TextStyle(color: Colors.white)),
						onPressed: () async {
							if (await downloadFromLink(context)) {
								Navigator.pop(context);
							}
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

Future downloadFromLink(BuildContext context) {
	String link;
	final _formKey = GlobalKey<FormState>();
	return showDialog(
			context: context,
			builder: (BuildContext context) {
				return SimpleDialog(
					backgroundColor: Colors.grey[800],
					title: Text("Download Noise from link", style: TextStyle(color: Colors.white)),
					children: [
						Form(
							key: _formKey,
							child: Column(
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
								mainAxisSize: MainAxisSize.max,
								children: [
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
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceAround,
										mainAxisSize: MainAxisSize.max,
										children: [
											RaisedButton(
													color: Colors.grey[700],
													highlightColor: Colors.green,
													onPressed: () {
														Navigator.pop(context, false);
													},
													child: Text("Back", style: TextStyle(color: Colors.white))
											),
											RaisedButton(
													color: Colors.grey[700],
													highlightColor: Colors.green,
													onPressed: () async {
														if (_formKey.currentState.validate()) {
															_formKey.currentState.save();
															print(downloadNoise(link));
															Navigator.pop(context, true);
														}
													},
													child: Text("Download", style: TextStyle(color: Colors.white))
											),
										],
									),
								],
							)
						)
					],
				);
			}
	);
}

Future downloadNoise(link) async {
	String _localPath = await _findLocalPath();
	final takskId = await FlutterDownloader.enqueue(
		url: link,
		savedDir: _localPath,
		showNotification: true,
		openFileFromNotification: true,
	);
	return takskId;
}

Future _findLocalPath() async {
	final directory = await getApplicationDocumentsDirectory();
	return directory.path;
}