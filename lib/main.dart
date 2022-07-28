import 'dart:convert';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'package:scan/scan.dart';

var apiURL = "https://api.obmeg.com/search";
ThemeData dark = ThemeData(
    // colorScheme: ColorScheme.dark(),
    scaffoldBackgroundColor: Color(0xFF102334),
    primaryColor: Color(0xFF1d91f4),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white));

void main() => runApp(MaterialApp(
      home: MyHome(),
      themeMode: ThemeMode.dark,
      darkTheme: dark,
      debugShowCheckedModeBanner: false,
    ));

class MyHome extends StatefulWidget {
  MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int goupValue = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset("assets/back.jpg",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: 70,
            title: Text(
              'BYF ticket Scanner',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 200,
                      child: Image.asset(
                        'assets/obm_logo.png',
                      )),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 27, top: 70, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio(
                          value: 0,
                          groupValue: goupValue,
                          onChanged: gate,
                        ),
                        Text("Main Gate",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                        Radio(
                          value: 1,
                          groupValue: goupValue,
                          onChanged: gate,
                        ),
                        Text("Falaky Gate",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 50, right: 50),
                    child: MaterialButton(
                      height: 57,
                      minWidth: 350,
                      color: Color(0xFF0EACE9),
                      highlightColor: Colors.red,
                      enableFeedback: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => QRViewExample(goupValue),
                        ));
                      },
                      child: Text(
                        'LET THE PARTY BEGAN',
                        style: TextStyle(color: Colors.white, fontSize: 21),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void gate(int? value) {
    setState(() {
      goupValue = value!;
    });
  }
}

class QRViewExample extends StatefulWidget {
  late int gate;
  QRViewExample(int g) {
    this.gate = g;
  }
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  ScanController controller = ScanController();
  String qrcode = 'Unknown';

  Widget statusIcon = Icon(
    Icons.camera_rounded,
    color: Color(0xFFFFFFFF),
  );
  String widgetText = "start scanning tickets to show their status";

  Color buttonColor = Color(0xFFFFAA00);
  Color statusColor = Colors.blueGrey;
  bool flashOn = false;
  bool isScanning = true;
  bool isLoading = false;
  late Widget statusWidget;

  void setDefault() {
    flashOn = false;
    buttonColor = Color(0xFFFFAA00);
    widgetText = "start scanning tickets to show their status";
    statusColor = Colors.blueGrey;
    statusIcon = Icon(
      Icons.camera_rounded,
      color: Color(0xFFFFFFFF),
    );
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pause();
    }
    controller.resume();
  }

  Future _asyncInputDialog(BuildContext context) async {
    String ticketData = '';
    return showDialog(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter code Manually'),
          content: new Row(
            children: [
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Ticket Code',
                    hintText: 'eg. m2pc-6cod-4j7d-3dac'),
                onChanged: (value) {
                  ticketData = value;
                },
              ))
            ],
          ),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('Check'),
              onPressed: () async {
                await checkCode(ticketData)
                    .then((value) => Navigator.pop(context));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    statusWidget = Padding(
      padding: EdgeInsets.fromLTRB(30, 20, 30, 30),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: statusColor),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widgetText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: buttonColor, onPressed: () {}, child: statusIcon),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF111111),
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              iconSize: 37,
              icon: Icon(flashOn ? Icons.flash_off : Icons.flash_on),
              color: Color(0xFFFE034A),
              onPressed: () {
                controller.toggleTorchMode();
                setState(() {
                  flashOn = !flashOn;
                });
              },
            ),
            IconButton(
              iconSize: 37,
              icon: Icon(isScanning ? Icons.stop : Icons.play_arrow),
              color: Color(0xFFFE034A),
              onPressed: () async {
                setDefault();
                setState(() {
                  isScanning = !isScanning;
                });
                isScanning ? controller.resume() : controller.pause();
              },
            ),
            SizedBox(
              width: 40,
            ),
            IconButton(
              iconSize: 37,
              icon: Icon(Icons.text_fields),
              color: Color(0xFFFE034A),
              onPressed: () async {
                setDefault();
                setState(() {});
                await _asyncInputDialog(context);
              },
            ),
            IconButton(
              iconSize: 37,
              icon: Icon(Icons.settings),
              color: Color(0xFFFE034A),
              onPressed: () {
                Vibration.cancel();
                super.dispose();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
              flex: 1,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                  : statusWidget)
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return SizedBox(
      width: 350, // custom wrap size
      height: 300,

      child: ScanView(
        controller: controller,
        scanAreaScale: 0.9,
        scanLineColor: Color(0xFFFE034A),
        onCapture: (data) {
          checkCode(data);
        },
      ),
    );
  }

  @override
  void dispose() {
    Vibration.cancel();
    super.dispose();
  }

  Future checkCode(String? code) async {
    Vibration.cancel();
    setState(() {
      isLoading = true;
    });
    try {
      String body =
          '{"code": "$code","gate":"${widget.gate == 0 ? "Main" : "Falaky"}"}';
      print("Body: " + body);
      var response = await http.post(
        Uri.parse(apiURL),
        body: body,
        headers: {"Content-Type": "application/json"},
      );
      //final responseData = await (jsonDecode(response.body));
      print("body: " + response.body);
      final responseData = await (jsonDecode(response.body));
      final result = responseData['message'];
      print(responseData);

      setState(() {
        isLoading = false;
        isScanning = false;
        statusIcon = Icon(
          result == "True"
              ? Icons.verified_user
              : result == "Entered"
                  ? Icons.people
                  : result == "Hold"
                      ? Icons.watch_later
                      : Icons.error,
          color: Colors.white,
        );
        buttonColor = result == "True"
            ? Colors.green
            : result == "Entered"
                ? Colors.black
                : result == "Hold"
                    ? Colors.amber
                    : Colors.red;
        statusColor = buttonColor;
        widgetText = result == "True"
            ? "Say Welcome :D"
            : result == "Entered"
                ? "he/she've entered once before :("
                : result == "Hold"
                    ? "Ask him/her to activate his ticket"
                    : "Invalid ticket!";
      });

      result == "True"
          ? Vibration.vibrate(pattern: [300, 100, 300, 100])
          : result == "Entered"
              ? Vibration.vibrate(duration: 3000)
              : result == "Hold"
                  ? Vibration.vibrate(duration: 300)
                  : Vibration.vibrate(pattern: [
                      300,
                      50,
                      300,
                      100,
                      300,
                      50,
                      300,
                      100,
                      300,
                      50,
                      300,
                      100
                    ]);

      return result;
    } catch (e) {
      print(e);
    }
  }
}
