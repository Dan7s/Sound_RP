import 'package:flutter/material.dart';

class NoiseTab extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black,
			body: Container(
				child: Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							Text(
								'Instant Noise List',
								style: TextStyle(color: Colors.green),
							),
						],
					),
				),
			),
		);
	}
}
