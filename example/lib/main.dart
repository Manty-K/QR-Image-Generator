import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qr_image_generator/qr_image_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Image Generator Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Click to Save QR',
            ),
            ElevatedButton(
              onPressed: saveQRImage,
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }

  Future saveQRImage() async {
    String? outputDir = await FilePicker.platform.getDirectoryPath();
    if (outputDir == null) {
      return;
    }

    final generator = QRGenerator();

    await generator.generate(
      data: 'Hello World!',
      filePath: '$outputDir/hello.png',
      scale: 10,
    );
  }
}
