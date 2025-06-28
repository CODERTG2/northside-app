import 'package:http/http.dart' as http;

fetchdata(String url) async {
  // URL can be /athletics or /roster or any other route seen in main.py
  url = "https://b8c7-2600-1700-67d0-50a0-00-46.ngrok-free.app/api$url";
  http.Response response = await http.get(Uri.parse(url));
  return response.body;
}