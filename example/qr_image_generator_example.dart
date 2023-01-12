import 'package:qr_image_generator/qr_image_generator.dart';

void main() async {
  final generator = QRGenerator();

  await generator.generate(
    data: 'Hello World!',
    filePath: 'hello.png',
    scale: 10,
  );
}
