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
   var aux = 'Bem-vindo! PFC MapAlarm - Felipe Ferraz, Rafael Chaves e Raffael Russo. Orientador: Maj Anderson.'; 
   res.add(aux.codeUnits);
    res.close();

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

      var flag = findUserDataInDB(jsonData['username'], jsonData['password'], res);
    },
        onError: printError);
  }else if(req.uri.path == '/signup') {
    req.listen((List<int> buffer) {
      var file = new File(DATA_FILE);
      var ioSink = file.openWrite(); // save the data to the file
      ioSink.add(buffer);
      var aux = new String.fromCharCodes(buffer);
      Map jsonData = JSON.decode(aux);
      var flag = sendUserDataToDB(jsonData['username'], jsonData['email'], jsonData['password'], res);
      print(flag);
      ioSink.close();

    },
        onError: printError);
  }else if(req.uri.path == '/alarm'){

    req.listen((List<int> buffer) {
      var aux = new String.fromCharCodes(buffer);
      print(buffer);
      Map jsonData = JSON.decode(aux);

      if(jsonData['param'] == 'insert'){
        var flag = insertUserAlarmToDB(jsonData['email'], jsonData['label'] , jsonData['endereco'] ,
              jsonData['lat'], jsonData['long'], jsonData['raio'], jsonData['status'], res);
            print(flag);
            print(res);

      }else if(jsonData['param'] == 'my_alarms'){
        var flag = findUserAlarmsInDB(jsonData['email'], res);
        print(flag);

      }else if(jsonData['param'] == 'update'){
        var flag = updateAlarmStatus(jsonData['email'], jsonData['label'], jsonData['status'], res);
        print(flag);
        print(res);

      }else if(jsonData['param'] == 'delete'){
        var flag = deleteAlarm(jsonData['email'], jsonData['label'], res);
        print(flag);
        print(res);

      }

    },
        onError: printError);
  }else{
      print("Rota nao autorizada.");
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
      }});
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


findUserDataInDB(String email, String senha, HttpResponse res){
var uri = 'postgres://mapalarmadminbd:majends123@mapalarmdb.cs14yv54tnrf.sa-east-1.rds.amazonaws.com:5432/mapalarmbd';
  connect(uri).then((conn) {
    print("QUERYING");
    print(senha);
    conn.query('SELECT password FROM users WHERE email = @email', {'email': email}).toList().then((rows) {
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

});

}

//BUSCANDO ALARMES NO BANCO DE DADOS DE ACORDO COM O USERNAME
bool findUserAlarmsInDB(String user_email, HttpResponse res){
  var uri = 'postgres://mapalarmadminbd:majends123@mapalarmdb.cs14yv54tnrf.sa-east-1.rds.amazonaws.com:5432/mapalarmbd';
  connect(uri).then((conn) {
    print("QUERYING ALARM FROM USER: " + user_email);
    //QUERYING
    conn.query(
        'SELECT * FROM alarms WHERE email = @email', {'email': user_email})
        .toList()
        .then((rows) {
      for (var row in rows) {
        print(row); // Refer to columns by name,
        //print(row[0]);   Or by column index.
        if (row[0] != null) {
          print(row);
          var i = 0;
          for(i = 2; i < 8; i++)
          {
          var aux = row[i].toString() + "|";
          res.add(aux.codeUnits);
          //res.add(row.codeUnits);
        }
        }
        else {
          print("no else");
          res.add([50]);
        }
      }
      res.close();
    });
  });
  return true;
 }

//INSERINDO ALARMES NO BANCO DE DADOS ASSOCIANDO AO USERNAME
bool insertUserAlarmToDB(String nome, String label, String endereco, num lat,num long, num raio, bool status, HttpResponse res){
  DateTime now = new DateTime.now();
  var uri = 'postgres://mapalarmadminbd:majends123@mapalarmdb.cs14yv54tnrf.sa-east-1.rds.amazonaws.com:5432/mapalarmbd';
  connect(uri).then((conn) {
    try{
      conn.execute('INSERT INTO alarms (EMAIL, LABEL, ADDRESS, LATITUDE, LONGITUDE, RADIO, STATUS ,CREATED_AT) values (@email, @label, @address, @latitude, @longitude, @radio, @status, @created_at)',
          {'email': nome, 'label': label, 'address': endereco, 'latitude': lat, 'longitude': long, 'radio': raio, 'status': status, 'created_at': now }).then((result) {
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

//UPDATE NO STATUS DO ALARME
bool updateAlarmStatus(String email, String label, bool status, HttpResponse res){
  var uri = 'postgres://mapalarmadminbd:majends123@mapalarmdb.cs14yv54tnrf.sa-east-1.rds.amazonaws.com:5432/mapalarmbd';
  connect(uri).then((conn) {
    try{
      conn.execute('UPDATE  alarms SET STATUS  = @status WHERE LABEL = @label AND EMAIL = @email',
          {'label': label, 'status': status, 'email':email}).then((result) {
        print(result);
        print('Status do alarme alterado com sucesso.');
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


//APAGANDO UM ALARME DA LISTA DO USUARIO
bool deleteAlarm( String email, String label, HttpResponse res){
  var uri = 'postgres://mapalarmadminbd:majends123@mapalarmdb.cs14yv54tnrf.sa-east-1.rds.amazonaws.com:5432/mapalarmbd';
  connect(uri).then((conn) {
    try{
      conn.execute('DELETE FROM alarms WHERE label = @label and email = @email',
          {'label': label, 'email': email}).then((result) {
        print(result);
        print('Alarme deletado com sucesso.');
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

void printError(error) => print(error);
