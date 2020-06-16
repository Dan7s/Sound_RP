import 'package:http/http.dart';
import 'package:beautifulsoup/beautifulsoup.dart';


Future<String> getTrackTitle(trackCode) async {
  var client = Client();
  Response response = await client.get('https://www.youtube.com/watch?v=' + trackCode);
  var soup = Beautifulsoup(response.body);
  String title = soup("title").text;
  title = title.substring(0, title.length-10);
  return title;
}