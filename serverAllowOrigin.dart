import 'dart:io';
import 'dart:convert';
import 'package:postgresql/postgresql.dart';

/* A simple web server that responds to **ALL** GET requests by returning
 * the contents of data.json file, and responds to ALL **POST** requests
 * by overwriting the contents of the data.json file
 * 
 * Browse to it using http://localhost:8080  
 * 
 * Provides CORS headers, so can be accessed from any other page
 */

//final HOST = "127.0.0.1"; // eg: localhost 
final HOST = InternetAddress.ANY_IP_V4;
final PORT = 8080; 
final DATA_FILE = "data.json";

void main(){
 HttpServer.bind(HOST, PORT).then((server) {
    server.listen((HttpRequest request) {
      switch (request.method) {
        case "GET": 
          handleGet(request);
          break;
        case "POST": 
          handlePost(request);
          break;
        case "OPTIONS": 
          handleOptions(request);
          break;
        default: defaultHandler(request);
      }
    }, 
    onError: printError);
    
    print("Listening for GET and POST on http://$HOST:$PORT");
  },
  onError: printError);
}

/**
 * Handle GET requests by reading the contents of data.json
 * and returning it to the client
 */
void handleGet(HttpRequest req) {
  HttpResponse res = req.response;
  print("${req.method}: ${req.uri.path}");
  addCorsHeaders(res);
  
  var file = new File(DATA_FILE);
  if (file.existsSync()) {
    res.headers.add(HttpHeaders.CONTENT_TYPE, "application/json");
    file.readAsBytes().asStream().pipe(res); // automatically close output stream
  }
  else {
    var err = "Could not find file: $DATA_FILE";
    res.addString(err);
    res.close();  
  }
  
}

/**
 * Handle POST requests by overwriting the contents of data.json
 * Return the same set of data back to the client.
 */
void handlePost(HttpRequest req) {
  HttpResponse res = req.response;
  print("${req.method}: ${req.uri.path}");
  
  addCorsHeaders(res);
   
 //Adding data to DB

//await for (req) {
   // ContentType contentType = req.headers.contentType;

     // try {
   //     var jsonString = await req.transform(UTF8.decoder).join();

 //       Map jsonData = JSON.decode(jsonString);
        
       // var flag = sendUserDataToDB(jsonData['name'], jsonData['email']);
     //   req.response
      //  ..statusCode = HttpStatus.OK
    //    ..write(flag)
  //      ..close();
      
//  } catch (e) {
    //  req.response..statusCode = HttpStatus.INTERNAL_SERVER_ERROR
    //  ..write("Exception during file I/O: $e.")
  //    ..close();
//      }

//}


//END


  req.listen((List<int> buffer) {
    var file = new File(DATA_FILE);
    var ioSink = file.openWrite(); // save the data to the file
    ioSink.add(buffer);
    var aux = new String.fromCharCodes(buffer);
    Map jsonData = JSON.decode(aux);
    var flag = sendUserDataToDB(jsonData['name'], jsonData['email']);    
   // var flag = sendUserDataToDB(buffer['name'], buffer['email']);
   print(flag); 
   ioSink.close();
    
    // return the same results back to the client
    res.add(buffer);
    res.close();
  },
  onError: printError);
}

/**
 * Add Cross-site headers to enable accessing this server from pages
 * not served by this server
 * 
 * See: http://www.html5rocks.com/en/tutorials/cors/ 
 * and http://enable-cors.org/server.html
 */
void addCorsHeaders(HttpResponse res) {
  res.headers.add("Access-Control-Allow-Origin", "*");
  res.headers.add("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
  res.headers.add("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
}

void handleOptions(HttpRequest req) {
  HttpResponse res = req.response;
  addCorsHeaders(res);
  print("${req.method}: ${req.uri.path}");
  res.statusCode = HttpStatus.NO_CONTENT;
  res.close();
}

void defaultHandler(HttpRequest req) {
  HttpResponse res = req.response;
  addCorsHeaders(res);
  res.statusCode = HttpStatus.NOT_FOUND;
  res.addString("Not found: ${req.method}, ${req.uri.path}");
  res.close();
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
void printError(error) => print(error);
