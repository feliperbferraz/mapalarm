import 'dart:io';
import 'dart:convert' show UTF8, JSON;
import 'packages/json_object/json_object.dart';
//import 'dart:html';

main() async {

  var jsonData = new JsonObject();

//    jsonData["name"] = querySelector('#username');
//    jsonData['email'] = querySelector('#email');
      jsonData["name"] = 'rafael';
      jsonData['email'] = 'chaves@365.com';

    var request = await new HttpClient().post(
        '52.67.76.53', 8080, '/signin');
    request.headers.contentType = ContentType.JSON;
    request.write(JSON.encode(jsonData));
    HttpClientResponse response = await request.close();
    await for (var contents in response.transform(UTF8.decoder)) {
    print(contents);
  }


}
