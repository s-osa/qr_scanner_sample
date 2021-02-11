import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'QR code scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScanResult scanResult;

  Future _scan() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'No camera permission';
        });
      } else {
        result.rawContent = 'Error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var contentList = <Widget>[
      if (scanResult != null)
        Card(
          child: Column(children: <Widget>[
            ListTile(
              title: Text('Result Type'),
              subtitle: Text(scanResult.type?.toString() ?? ''),
            ),
            ListTile(
              title: Text('RawContent'),
              subtitle: Text(scanResult.rawContent ?? ''),
            ),
            ListTile(
              title: Text('Format'),
              subtitle: Text(scanResult.format?.toString() ?? ''),
            ),
            ListTile(
              title: Text('Format note'),
              subtitle: Text(scanResult.formatNote ?? ''),
            ),
          ]),
        ),
      ListTile(
        title: Text('カメラを起動してください'),
        subtitle: Text('QRコードを読み取ってください'),
      ),
    ];

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: contentList,
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: _scan,
              tooltip: 'Scan',
              child: Icon(Icons.qr_code_scanner)),
        ));
  }
}
