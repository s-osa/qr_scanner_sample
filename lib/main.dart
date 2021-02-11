import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:qr_scanner_sample/db_provider.dart';
import 'package:qr_scanner_sample/scan_history.dart';

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
  List<ScanHistory> scanHistories = [];

  Future _scan() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() => scanResult = result);

      var newScanHistory = new ScanHistory(payload: result.rawContent);
      DBProvider.db.newScanHistory(newScanHistory);
      scanHistories.add(newScanHistory);
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

    final tiles = scanHistories.map((ScanHistory sh) {
      return ListTile(
        title: Text(sh.payload),
      );
    });
    final divided = ListTile.divideTiles(context: context, tiles: tiles).toList();

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: contentList + divided,
          ),
          floatingActionButton: FloatingActionButton(onPressed: _scan, tooltip: 'Scan', child: Icon(Icons.qr_code_scanner)),
        ));
  }
}
