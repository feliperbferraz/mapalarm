import 'dart:io';
import 'dart:convert';
import 'package:postgresql/postgresql.dart';


main() async {
  var server =
  await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080);

  await for (var req in server) {
    ContentType contentType = req.headers.contentType;

    if (req.method == 'POST' &&
               contentType != null &&
    contentType.mimeType == 'application/json') {
      try {
        var jsonString = await req.transform(UTF8.decoder).join();
        var pathRoute = req.uri.pathSegments.last;
        // Write to a file, get the file name from the URI.
//        await new File(filename).writeAsString(jsonString,
//            mode: FileMode.WRITE);

        Map jsonData = JSON.decode(jsonString);
        if(pathRoute == 'signin') {
          var flag = sendUserDataToDB(jsonData['name'], jsonData['email']);
          req.response
            ..statusCode = HttpStatus.OK
            ..write(flag)
            ..close();
        } else{
          req.response..statusCode = HttpStatus.INTERNAL_SERVER_ERROR
            ..write('PATH DOES NOT EXIST')
            ..close();
        }
      } catch (e) {
        req.response..statusCode = HttpStatus.INTERNAL_SERVER_ERROR
          ..write("Exception during file I/O: $e.")
          ..close();
      }
    } else {
      req.response..statusCode = HttpStatus.METHOD_NOT_ALLOWED
        ..write("Unsupported request: ${req.method}.")
        ..close();
    }
  }
}


bool sendUserDataToDB(String nome, String email){
  DateTime now = new DateTime.now();
  var uri = 'postgres://mapalarmadminbd:majends123@mapalarmdb.cs14yv54tnrf.sa-east-1.rds.amazonaws.com:5432/mapalarmbd';
  connect(uri).then((conn) {

    //QUERYING
    conn.query('select * from users').toList().then((rows) {
      for (var row in rows) {
        print(row.name); // Refer to columns by name,
        print(row[0]);    // Or by column index.
      }
    });

    //EXECUTING INSERT A NEW USER
    conn.execute('insert into users (NAME, EMAIL, CREATED_AT) values (@name, @email, @created_at)',
        {'name': nome, 'email': email, 'created_at': now }).then((_) {

        print('done!');

    });

  });
  return true;
}