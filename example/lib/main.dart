import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:adhara_socket_io/adhara_socket_io.dart';

void main() => runApp(MyApp());

const String URI = "http://192.168.0.114:7000/";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> toPrint = ["trying to conenct"];
  SocketIOManager manager;
  SocketIO socket;
  bool isProbablyConnected = false;

  @override
  void initState() {
    super.initState();
    manager = SocketIOManager();
    initSocket();
  }

  initSocket() async {
    setState(() => isProbablyConnected = true);
    socket = await manager.createInstance(SocketOptions(
      //Socket IO server URI
        URI,
        //Query params - can be used for authentication
        query: {
          "auth": "--SOME AUTH STRING---",
          "info": "new connection from adhara-socketio",
          "timestamp": DateTime.now().toString()
        },
        //Enable or disable platform channel logging
        enableLogging: false,
        transports: [Transports.WEB_SOCKET, Transports.POLLING] //Enable required transport
    ));
    socket.onConnect((data) {
      pprint("connected...");
      pprint(data);
      sendMessage();
    });
    socket.onConnectError(pprint);
    socket.onConnectTimeout(pprint);
    socket.onError(pprint);
    socket.onDisconnect(pprint);
    socket.on("type:string", (data) => pprint("type:string | $data"));
    socket.on("type:bool", (data) => pprint("type:bool | $data"));
    socket.on("type:number", (data) => pprint("type:number | $data"));
    socket.on("type:object", (data) => pprint("type:object | $data"));
    socket.on("type:list", (data) => pprint("type:list | $data"));
    socket.on("message", (data) => pprint(data));
    socket.connect();
  }

  disconnect() async {
    await manager.clearInstance(socket);
    setState(() => isProbablyConnected = false);
  }

  sendMessage() {
    if (socket != null) {
      pprint("sending message...");
      socket.emit("message", [
        "Hello world!",
        1908,
        {
          "wonder": "Woman",
          "comics": ["DC", "Marvel"]
        },
        {
          "test": "=!./"
        },
        [
          "I'm glad",
          2019,
          {
            "come back": "Tony",
            "adhara means": ["base", "foundation"]
          },
          {
            "test": "=!./"
          },
        ]
      ]);
      pprint("Message emitted...");
    }
  }

  sendMessageWithACK(){
    pprint("Sending ACK message...");
    List msg = ["Hello world!", 1, true, {"p":1}, [3,'r']];
    socket.emitWithAck("ack-message", msg).then( (data) {
      // this callback runs when this specific message is acknowledged by the server
      pprint("ACK recieved for $msg: $data");
    });
  }

  pprint(data) {
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }
      print(data);
      toPrint.add(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: TextTheme(
            title: TextStyle(color: Colors.white),
            headline: TextStyle(color: Colors.white),
            subtitle: TextStyle(color: Colors.white),
            subhead: TextStyle(color: Colors.white),
            body1: TextStyle(color: Colors.white),
            body2: TextStyle(color: Colors.white),
            button: TextStyle(color: Colors.white),
            caption: TextStyle(color: Colors.white),
            overline: TextStyle(color: Colors.white),
            display1: TextStyle(color: Colors.white),
            display2: TextStyle(color: Colors.white),
            display3: TextStyle(color: Colors.white),
            display4: TextStyle(color: Colors.white),
          ),
          buttonTheme: ButtonThemeData(
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
              disabledColor: Colors.lightBlueAccent.withOpacity(0.5),
              buttonColor: Colors.lightBlue,
              splashColor: Colors.cyan
          )
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Adhara Socket.IO example'),
          backgroundColor: Colors.black,
          elevation: 0.0,
        ),
        body: Container(
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Center(
                    child: ListView(
                      children: toPrint.map((String _) => Text(_ ?? "")).toList(),
                    ),
                  )
              ),
              Container(
                height: 60.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: RaisedButton(
                        child: Text("Connect"),
                        onPressed: isProbablyConnected?null:initSocket,
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        child: RaisedButton(
                          child: Text("Send Message"),
                          onPressed: isProbablyConnected?sendMessage:null,
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                        )
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        child: RaisedButton(
                          child: Text("Send w/ ACK"), //Send message with ACK
                          onPressed: isProbablyConnected?sendMessageWithACK:null,
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                        )
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        child: RaisedButton(
                          child: Text("Disconnect"),
                          onPressed: isProbablyConnected?disconnect:null,
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                        )
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.0,)
            ],
          ),
        ),
      ),
    );
  }
}
