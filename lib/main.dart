import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:desktop_window/desktop_window.dart';
import 'dart:async';
import 'dart:io';

//HTTP
import 'package:http/http.dart' as http;

bool testFlag(int value, int attribute) => value & attribute == attribute;
//Gets power status object
SYSTEM_POWER_STATUS getPowerStatus() {
  final powerStatus = SYSTEM_POWER_STATUS.allocate();

  try{
    final result = GetSystemPowerStatus(powerStatus.addressOf);
    if(result != 0) {
      return powerStatus;
    } else {
      throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
    }
  } finally {
    free(powerStatus.addressOf);
  }
}

//Gets power info
void printPowerInfo() {
  final powerStatus = SYSTEM_POWER_STATUS.allocate();

  try {
    final result = GetSystemPowerStatus(powerStatus.addressOf);
    if (result != 0) {
      print('Power status from GetSystemPowerStatus():');

      if (powerStatus.ACLineStatus == 0) {
        print(' - Disconnected from AC power.');
      } else if (powerStatus.ACLineStatus == 1) {
        print(' - Connected to AC power.');
      } else {
        print(' - AC power status unknown.');
      }

      if (testFlag(powerStatus.BatteryFlag, 128)) {
        print(' - No battery installed.');
      } else {
        if (powerStatus.BatteryLifePercent == 255) {
          print(' - Battery status unknown.');
        } else {
          print(
              ' - ${powerStatus.BatteryLifePercent}% percent battery remaining.');
        }

        if (powerStatus.BatteryLifeTime != 0xFFFFFFFF) {
          print(
              ' - ${powerStatus.BatteryLifeTime / 60} minutes of power estimated to remain.');
        }
        // New in Windows 10, but should report 0 on older systems
        if (powerStatus.SystemStatusFlag == 1) {
          print(' - Battery saver is on. Save energy where possible.');
        }
      }
    } else {
      throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
    }
  } finally {
    free(powerStatus.addressOf);
  }
}

String printReadableStatus(){
  SYSTEM_POWER_STATUS powerStatus;
  powerStatus = getPowerStatus();
  if (powerStatus.ACLineStatus == 0) {
    return ' - Disconnected from AC power.';
  } else if (powerStatus.ACLineStatus == 1) {
    return ' - Connected to AC power.';
  } else {
    return ' - AC power status unknown.';
  }
}

//Sends a message from bot <token> to chat <myId>
Future<http.Response> sendMessage(String token, String myId, String myMessage) async{
  final http.Response response = await http.post(
    'https://api.telegram.org/bot'+ token + '/sendMessage',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'text': myMessage,
      'chat_id' : myId
    }),
  );
  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    print("Funziona");
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}


void main() {
  //Get your bot token: https://core.telegram.org/bots#6-botfather
  var token = "<your_token>";

  //Get your Telegram chat id: https://stackoverflow.com/a/54818656/4820276
  var myId = "<your_chat_id>";
  final file = new File('myBotInfos.txt');
  Stream<List<int>> inputStream = file.openRead();

  inputStream
  .transform(utf8.decoder)       // Decode bytes to UTF-8.
  .transform(new LineSplitter()) // Convert stream to individual lines.
  .listen((String line) {        // Process results.
    print('$line: ${line.length} bytes');
  },
    onDone: () {
      print('File is now closed.'); },
    onError: (e) {
      print(e.toString());
    }
  );


  var url = 'https://api.telegram.org/bot'+ token;
  sendMessage(token, myId, "Bot started");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check AC Line Connection',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Prova Battery'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status;
  //Gets window size
  String _windowSize = 'Unknown';

  Future _getWindowSize() async {
    var size = await DesktopWindow.getWindowSize();
    setState(() {
      _windowSize = '${size.width} x ${size.height}';
    });
  }

  @override
  void initState(){
    Timer.periodic(Duration(seconds:1), (Timer t)=>_incrementCounter());
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _status = printReadableStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_status',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text('PowerInfo'),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
