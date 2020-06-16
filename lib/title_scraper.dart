//This is simple youtube title web scrapper.

import 'package:http/http.dart';

Future<String> getTrackTitle(trackCode) async {
  var client = Client();
  String title = "";
  String document = "";
  try {
    Response response = await client.get('https://www.youtube.com/watch?v=' + trackCode);
    document = response.body;
    title = document.substring(document.indexOf("<title>"), document.indexOf("</title>"));
    title = title.substring(7, title.length-10);
  } catch (SocketException) {
    title = "Youtube Video";
  }
  return title;
}