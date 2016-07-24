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
//  req.uri.
//  print(req);
//  req.listen((List<int> buffer) {
 //   var aux = new String.fromCharCodes(buffer);
 //   print(buffer);
  //  Map jsonData = JSON.decode(aux);
   // var flag = findUserDataInDB(jsonData['name'], jsonData['email']);
    // var flag = sendUserDataToDB(buffer['name'], buffer['email']);
   // print(flag);
   // res.headers.add(HttpHeaders.CONTENT_TYPE, "application/json");
   var aux = 'Bem-vindo! PFC MapAlarm - Felipe Ferraz, Rafael Chaves e Raffael Russo. Orientador: Maj Anderson.'; 
   res.add(aux.codeUnits);
  //},
   //   onError: printError);

//  var file = new File(DATA_FILE);
//  if (file.existsSync()) {
//    res.headers.add(HttpHeaders.CONTENT_TYPE, "application/json");
//    file.readAsBytes().asStream().pipe(res); // automatically close output stream
//  }
//  else {
//    var err = "Could not find file: $DATA_FILE";
//    res.addString(err);

    res.close();
//  }

}

/**
 * Handle POST requests by overwriting the contents of data.json
 * Return the same set of data back to the client.
 */
void handlePost(HttpRequest req) {
  HttpResponse res = req.response;
  print("${req.method}: ${req.uri.path}");

  addCorsHeaders(res);
 print(req.uri.path);
  if(req.uri.path == '/login'){
    req.listen((List<int> buffer) {
      var aux = new String.fromCharCodes(buffer);
      print("DENTRO DO /LOGIN");
      print(buffer);
      Map jsonData = JSON.decode(aux);
      //print(jsonData['name']);
      
      var flag = findUserDataInDB(jsonData['username'], jsonData['password'], res);
      // var flag = sendUserDataToDB(buffer['name'], buffer['email']);
     // print(flag);
//      res.headers.add(HttpHeaders.CONTENT_TYPE, "application/json");
      //if(flag){
       // res.add([1]); }
      //else{
       // res.add([2]); }
     // res.add(jsonData);
     // res.close();
    },
        onError: printError);
  }else{
    req.listen((List<int> buffer) {
      var file = new File(DATA_FILE);
      var ioSink = file.openWrite(); // save the data to the file
      ioSink.add(buffer);
      var aux = new String.fromCharCodes(buffer);
      Map jsonData = JSON.decode(aux);
      var flag = sendUserDataToDB(jsonData['username'], jsonData['email'], jsonData['password'], res);
      // var flag = sendUserDataToDB(buffer['name'], buffer['email']);
      print(flag);
      ioSink.close();

      // return the same results back to the client
     // res.add(buffer);
    //  res.close();
    },
        onError: printError);
  }

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

bool sendUserDataToDB(String nome, String email, String senha, HttpResponse res){
  DateTime now = new DateTime.now();
  var uri = 'postgres://mapalarmadminbd:majends123@mapalarmdb.cs14yv54tnrf.sa-east-1.rds.amazonaws.com:5432/mapalarmbd';
  connect(uri).then((conn) {

    //QUERYING
    conn.query('SELECT 1 FROM users WHERE username = @username', {'username': nome}).toList().then((rows) {
      for (var row in rows) {
       // print(row.username); // Refer to columns by name,
        print(row[0]);    // Or by column index.
        if(row[0] ==1){
        res.add([50]);
        res.close();  
        conn.close();
        }   
      }
    });

    conn.query('SELECT 1 FROM users WHERE email = @email', {'email':email}).toList().then((rows) {
      for (var row in rows) {
       // print(row.username); // Refer to columns by name,
        print(row[0]);    // Or by column index.
        if(row[0] ==1){
        res.add([50]);
        res.close();
        conn.close();  
        }
      //else{
      //      conn.execute('insert into users (USERNAME, EMAIL,PASSWORD, CREATED_AT) values (@username, @email,@password, @created_at)',
      //  {'username': nome, 'email': email, 'password': senha, 'created_at': now }).then((_) { 
      //print('done!');
      //var aux = 'usuario incluido';
      //res.add(aux.codeUnits);
      //res.close();
      //conn.close();
      
    //});
    
  //}
       }});

         
     // }
   // );


    //EXECUTING INSERT A NEW USER
   try{
    conn.execute('insert into users (USERNAME, EMAIL,PASSWORD, CREATED_AT) values (@username, @email,@password, @created_at)',
        {'username': nome, 'email': email, 'password': senha, 'created_at': now }).then((result) {
      print(result);
      print('done!');
      res.add([49]);
      res.close();
      conn.close();

     });
    } catch(e){
        print(e);
        res.add([50]);
        res.close();
         }
  });

  return true;
}


findUserDataInDB(String nome, String senha, HttpResponse res){
 // DateTime now = new DateTime.now();
print("URI");
var uri = 'postgres://mapalarmadminbd:majends123@mapalarmdb.cs14yv54tnrf.sa-east-1.rds.amazonaws.com:5432/mapalarmbd';
  connect(uri).then((conn) {
    print("QUERYING");
    print(senha);
    //QUERYING
    conn.query('SELECT password FROM users WHERE username = @username', {'username': nome}).toList().then((rows) {
      for (var row in rows) {
        print("Usuario cadastrado"); // Refer to columns by name,
        print(row[0]);    // Or by column index.
        if(row[0] != null){
           res.add(row[0].codeUnits);}
        else{
          print("no else");
          res.add([50]);}
      }
    res.close(); 
    });

    //EXECUTING INSERT A NEW USER
//    conn.execute('insert into users (NAME, EMAIL, CREATED_AT) values (@name, @email, @created_at)',
//        {'name': nome, 'email': email, 'created_at': now }).then((_) {
//
//      print('done!');
//
//    });

});

}


void printError(error) => print(error);
