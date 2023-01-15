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
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'QR Image Generator Demo'),
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
  final TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Enter Text',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 10),
              TextFormField(
                controller: textEditingController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: saveQRImage,
                child: const Text('Save QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future saveQRImage() async {
    FocusScope.of(context).unfocus();
    String? filePath = await FilePicker.platform.saveFile(
      fileName: 'demoQr.png',
      type: FileType.image,
    );
    if (filePath == null) {
      return;
    }

    final generator = QRGenerator();

    await generator.generate(
      data: textEditingController.text,
      filePath: filePath,
      scale: 10,
      padding: 2,
      foregroundColor: Colors.yellow,
      backgroundColor: Colors.blue,
      errorCorrectionLevel: ErrorCorrectionLevel.medium,
    );
  }
}
