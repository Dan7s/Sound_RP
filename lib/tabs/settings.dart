import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
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
								'Settings',
								style: TextStyle(color: Colors.green),
							)
						],
					),
				),
			),
		);
	}
}
