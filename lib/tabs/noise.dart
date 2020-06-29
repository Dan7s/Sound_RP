import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

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
		_initDownloader();
		super.initState();
	}

	void _initDownloader() async {
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
						addNoise();
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