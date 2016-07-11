
import 'dart:io';
import 'dart:math' show Random;
import 'package:postgresql/postgresql.dart';
import 'dart:convert';


int myNumber = new Random().nextInt(10);

main() async {
  print("I'm thinking of a number: $myNumber");
  DateTime now = new DateTime.now();
  var address  = InternetAddress.ANY_IP_V4;
  var requestServer =
  await HttpServer.bind(address, 8082);
  print('listening on ${address}, port ${requestServer.port}');

  var uri = 'postgres://mapalarmadminbd:majends123@mapalarmdb.cs14yv54tnrf.sa-east-1.rds.amazonaws.com:5432/mapalarmbd';
  connect(uri).then((conn) {

    //QUERYING
    conn.query('select * from users').toList().then((rows) {
      for (var row in rows) {
        print(row.name); // Refer to columns by name,
        print(row[0]);    // Or by column index.
      }
    });

    var data = {'nome':'felipe123', 'email':'fjhkjh@lkjlk.com'};
//    Map jsonData = JSON.decode(data.transform(UTF8.decoder).join());
    //EXECUTING INSERT A NEW USER insert into users (NAME, EMAIL, CREATED_AT) values ('felipe122', 'f2@2.com', now());
    conn.execute('insert into users (NAME, EMAIL, CREATED_AT) values (@name, @email, @created_at)',
                  {'name': data['nome'], 'email': data['email'], 'created_at': now }).then((_) { print(data); });

    });

//  });

//  await for (var request in requestServer) {
//    handleRequest(request);
//  }

//  var uri = 'postgres://mapalarmadminbd:majends123@mapalarmdb.cs14yv54tnrf.sa-east-1.rds.amazonaws.com:5432/database';
//  connect(uri).then((conn) {
//    //Querying
//    print(conn);
//    conn.query('select color from crayons').toList().then((rows) {
//      for (var row in rows) {
//        print(row.color); // Refer to columns by name,
//        print(row[0]);    // Or by column index.
//      }
//    });
//
//    conn.execute("update crayons set color = 'pink'").then((rowsAffected) {
//      print(rowsAffected);
//    });
//
//    conn.query('select color from crayons where id = @id', {'id': 5})
//        .toList()
//        .then((result) { print(result); });
//
//    conn.execute('insert into crayons values (@id, @color)',
//        {'id': 1, 'color': 'pink'})
//        .then((_) { print('done.'); });

//  });
//
//  Connection.close()
}


void handleRequest(HttpRequest request) {
  try {
    if (request.method == 'GET') {
      handleGet(request);
      print('to no GET');
    } else {
      request.response..statusCode = HttpStatus.METHOD_NOT_ALLOWED
        ..write('Unsupported request: ${request.method}.')
        ..close();
      }
    } catch (e) {
        print('Exception in handleRequest: $e');
      }
  print('Request handled.');
}

void handleGet(HttpRequest request) {
  var guess = request.uri.queryParameters['q'];
  //request.response.statusCode = HttpStatus.OK;
  if (guess == myNumber.toString()) {
    request.response..writeln('true')
      ..writeln("I'm thinking of another number.")
      ..close();

  }
  else {
    request.response..writeln('Numero errado!')
    ..close();
  }
}
