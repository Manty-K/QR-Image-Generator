library qr_image_generator;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr/qr.dart';
import 'package:image/image.dart' as img;

class QRGenerator {
  late String _selectedData;

  late List<List<bool>> _imageData;

  late String _outputFilePath;

  late int _scale;

  late int _padding;

  late Color _bgColor;
  late Color _fgColor;

  late ErrorCorrectionLevel _errorCorrectionLevel;

  String? _tempDirPath;

  String get tempFilePath {
    final splitted = _outputFilePath.split('/');

    final filename = splitted.removeLast();

    final newFilename = 'temp_$filename';

    final filepath = '$_tempDirPath/$newFilename';

    return filepath;
  }

  /// Generate and save QR Code
  ///
  /// String [data] to be converted to QR Code.
  ///
  /// The image will be saved at [filePath].
  ///
  /// [padding] is size of a QR Module. Default is 1.
  ///
  /// [backgroundColor] color of a QR. Defaults to [Colors.white].
  ///
  /// [foregroundColor] of a QR. Defaults to [Colors.black].
  ///
  /// Choose [errorCorrectionLevel] between low,medium,quartile and high. Defaults to [ErrorCorrectionLevel.medium]
  Future<String> generate({
    required String data,
    required String filePath,
    int scale = 5,
    int padding = 1,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
    ErrorCorrectionLevel errorCorrectionLevel = ErrorCorrectionLevel.medium,
  }) async {
    /// Use assert statements

    if (padding <= 0) {
      throw 'Padding should be more than 0';
    }

    if (scale <= 0) {
      throw 'Scale should be more than 0';
    }

    if (data.trim().isEmpty) {
      throw 'Data should not be empty';
    }

    if (!filePath.endsWith('.png')) {
      throw 'File should end with .png';
    }

    _selectedData = data;
    _outputFilePath = filePath;
    _scale = scale;
    _padding = padding;
    _bgColor = backgroundColor;
    _fgColor = foregroundColor;
    _errorCorrectionLevel = errorCorrectionLevel;

    if (_tempDirPath == null) {
      final tempDir = await getTemporaryDirectory();
      _tempDirPath = tempDir.path;
    }

    try {
      await _makeImage();
      return filePath;
    } catch (e) {
      throw 'Generate Image Error';
    }
  }

  Future<void> _makeImage() async {
    final qr = QrCode(4, _errorCorrectionLevelInt(_errorCorrectionLevel))
      ..addData(_selectedData);

    final qrImage = QrImage(qr);

    _imageData = _getModules(qrImage);

    await _makeMiniImage();

    await _enlarge();
  }

  Future<void> _makeMiniImage() async {
    final data = _imageData;

    final spacing = _padding;

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
    await File(tempFilePath).writeAsBytes(png);
  }

  Future _enlarge() async {
    final imagePath = tempFilePath;
    final cmd = img.Command()
      ..decodeImageFile(imagePath)
      ..copyResize(width: _imageData.length * _scale)
      ..writeToFile(_outputFilePath);

    await cmd.executeThread();

    _deleteMini();
  }

  Future<void> _deleteMini() async {
    await File(tempFilePath).delete();
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

int _errorCorrectionLevelInt(ErrorCorrectionLevel level) {
  switch (level) {
    case ErrorCorrectionLevel.low:
      return QrErrorCorrectLevel.L;
    case ErrorCorrectionLevel.medium:
      return QrErrorCorrectLevel.M;
    case ErrorCorrectionLevel.quartile:
      return QrErrorCorrectLevel.Q;
    case ErrorCorrectionLevel.high:
      return QrErrorCorrectLevel.H;
  }
}

/// QR Code has error correction capability to restore data if the code is dirty or damaged.
/// Four error correction levels are available for users to choose according to the operating environment.
/// Raising this level improves error correction capability but also increases the amount of data QR Code size.
/// To select error correction level, various factors such as the operating environment and QR Code size need to be considered.
/// [ErrorCorrectionLevel.quartile] or [ErrorCorrectionLevel.high] may be selected for factory environment where QR Code get dirty,
/// whereas [ErrorCorrectionLevel.low] may be selected for clean environment with the large amount of data.
/// Typically, [ErrorCorrectionLevel.medium] (15%) is most frequently selected.
enum ErrorCorrectionLevel {
  low,
  medium,
  quartile,
  high,
}
