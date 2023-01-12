import 'dart:io';
import 'package:qr/qr.dart';
import 'package:image/image.dart' as img;

class QRGenerator {
  late String _selectedData;

  late List<List<bool?>> _imageData;

  late String _filename;

  late int _scale;

  final _initialImageName = 'mini.png';

  Future<void> generate({
    required String data,
    required String filePath,
    int scale = 4,
  }) async {
    _selectedData = data;
    _filename = filePath;
    _scale = scale;
    await _makeImage();
  }

  Future<void> _makeImage() async {
    final qr = QrCode(4, QrErrorCorrectLevel.H)..addData(_selectedData);

    final qrImage = QrImage(qr);

    _imageData = qrImage.qrModules;

    await _makeMiniImage();

    await _enlarge();
  }

  _makeMiniImage() async {
    final data = _imageData;

    final image = img.Image(
      width: data.length,
      height: data.length,
    );

    for (int i = 0; i < data.length; i++) {
      final row = data[i];
      for (int j = 0; j < row.length; j++) {
        final d = row[j];
        if (d == null) {
          continue;
        }

        img.Color c = img.ColorRgb8(255, 255, 255);

        if (d) {
          c = img.ColorRgb8(0, 0, 0);
        }
        image.setPixel(i, j, c);
      }
    }

    final png = img.encodePng(image);
    await File(_initialImageName).writeAsBytes(png);
  }

  Future _enlarge() async {
    final imagePath = _initialImageName;
    final cmd = img.Command()
      ..decodeImageFile(imagePath)
      ..copyResize(width: _imageData.length * _scale)
      ..writeToFile('hello/$_filename');

    await cmd.executeThread();

    _deleteMini();
  }

  Future<void> _deleteMini() async {
    await File(_initialImageName).delete();
  }
}
