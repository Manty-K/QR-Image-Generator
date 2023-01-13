library qr_image_generator;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import 'package:image/image.dart' as img;

class QRGenerator {
  late String _selectedData;

  late List<List<bool>> _imageData;

  late String _outputFilePath;

  late int _scale;

  late int _spacing;

  late Color _bgColor;
  late Color _fgColor;

  String get _miniPath {
    final splitted = _outputFilePath.split('/');

    final filename = splitted.removeLast();

    final newFilename = 'minified_$filename';

    splitted.add(newFilename);

    final minifiedpath = splitted.join('/');

    return minifiedpath;
  }

  /// Generate and save QR Code
  Future<String> generate({
    /// String data to be converted to QR Code
    required String data,

    ///The image will be saved at [filePath]
    required String filePath,
    int scale = 5,

    /// Size of a QR Module. Default is 1.
    int spacing = 1,

    /// Default [Colors.white]
    Color backgroundColor = Colors.white,

    /// Default [Colors.black]
    Color foregroundColor = Colors.black,
  }) async {
    if (data.trim().isEmpty) {
      throw 'Data should not be empty';
    }

    if (!filePath.endsWith('.png')) {
      throw 'File should end with .png';
    }

    _selectedData = data;
    _outputFilePath = filePath;
    _scale = scale;
    _spacing = spacing;
    _bgColor = backgroundColor;
    _fgColor = foregroundColor;

    try {
      await _makeImage();
      return filePath;
    } catch (e) {
      throw 'Generate Image Error';
    }
  }

  Future<void> _makeImage() async {
    final qr = QrCode(4, QrErrorCorrectLevel.H)..addData(_selectedData);

    final qrImage = QrImage(qr);

    _imageData = _getModules(qrImage);

    await _makeMiniImage();

    await _enlarge();
  }

  Future<void> _makeMiniImage() async {
    final data = _imageData;

    final spacing = _spacing;

    final image = img.Image(
      width: data.length + (spacing * 2),
      height: data.length + (spacing * 2),
    );

    ///Background mapping
    for (int i = 0; i < data.length + (spacing * 2); i++) {
      for (int j = 0; j < data.length + (spacing * 2); j++) {
        image.setPixel(i, j, _convertMaterialColorToImageColor(_bgColor));
      }
    }

    /// QR Code Mapping
    for (int i = 0; i < data.length; i++) {
      final row = data[i];
      for (int j = 0; j < row.length; j++) {
        final d = row[j];

        if (d) {
          /// Foreground Color
          img.Color c = _convertMaterialColorToImageColor(_fgColor);
          image.setPixel(i + spacing, j + spacing, c);
        }
      }
    }

    final png = img.encodePng(image);
    await File(_miniPath).writeAsBytes(png);
  }

  Future _enlarge() async {
    final imagePath = _miniPath;
    final cmd = img.Command()
      ..decodeImageFile(imagePath)
      ..copyResize(width: _imageData.length * _scale)
      ..writeToFile(_outputFilePath);

    await cmd.executeThread();

    _deleteMini();
  }

  Future<void> _deleteMini() async {
    await File(_miniPath).delete();
  }

  List<List<bool>> _getModules(QrImage image) {
    List<List<bool>> qrdata = [];

    /// Add empty lists
    for (int i = 0; i < image.moduleCount; i++) {
      qrdata.add([]);
    }

    /// Add Data
    for (var x = 0; x < image.moduleCount; x++) {
      for (var y = 0; y < image.moduleCount; y++) {
        if (image.isDark(y, x)) {
          // render a dark square on the canvas
          qrdata[x].add(true);
        } else {
          qrdata[x].add(false);
        }
      }
    }
    return qrdata;
  }
}

img.Color _convertMaterialColorToImageColor(Color c) {
  return img.ColorRgba8(c.red, c.green, c.blue, c.alpha);
}
