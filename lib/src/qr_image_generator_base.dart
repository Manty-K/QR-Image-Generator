import 'dart:io';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

class QRGenerator {
  late String _selectedData;

  late List<List<bool>> _imageData;

  late String _outputFilePath;

  late int _scale;

  late int _padding;

  late Color _bgColor;
  late Color _fgColor;

  late ErrorCorrectionLevel _errorCorrectionLevel;

  int? _qrVersion;

  /// Generate and save QR Code
  Future<String> generate({
    /// String [data] to be converted to QR Code.
    required String data,

    /// The image will be saved at [filePath].
    required String filePath,

    /// Scale factor of QR Code. Default is 5.
    int scale = 5,

    /// [padding] factor around QR Code. Default is 1.
    int padding = 1,

    /// [backgroundColor] color of a QR. Defaults to [Colors.white].
    Color backgroundColor = const Color.fromRGBO(255, 255, 255, 1),

    /// [foregroundColor] of a QR. Defaults to [Colors.black].
    Color foregroundColor = const Color.fromRGBO(0, 0, 0, 1),

    /// Choose [errorCorrectionLevel] between low, medium, quartile and high. Defaults to [ErrorCorrectionLevel.medium].
    ErrorCorrectionLevel errorCorrectionLevel = ErrorCorrectionLevel.medium,

    /// Generator automatically sets version from data. But you can also explicitly set qr version [1 - 40];
    int? qrVersion,
  }) async {
    // ? Use assert statements

    if (padding < 0) {
      throw 'Padding should not be negative';
    }

    if (scale <= 0) {
      throw 'Scale should be more than 0';
    }

    if (data.trim().isEmpty) {
      throw 'Data should not be empty';
    }

    if (!filePath.endsWith('.png')) {
      throw 'Filename should end with .png';
    }

    if (qrVersion != null) {
      if (qrVersion > 40 || qrVersion < 1) {
        throw 'QR version should be 1 - 40';
      }
    }

    _selectedData = data;
    _outputFilePath = filePath;
    _scale = scale;
    _padding = padding;
    _bgColor = backgroundColor;
    _fgColor = foregroundColor;
    _errorCorrectionLevel = errorCorrectionLevel;
    _qrVersion = qrVersion;

    try {
      await _makeImage();
      return filePath;
    } catch (e) {
      throw 'Generate Image Error';
    }
  }

  Future<void> _makeImage() async {
    late QrCode qr;

    if (_qrVersion == null) {
      qr = QrCode.fromData(
          data: _selectedData,
          errorCorrectLevel: _errorCorrectionLevelInt(_errorCorrectionLevel));
    } else {
      qr = QrCode(_qrVersion!, _errorCorrectionLevelInt(_errorCorrectionLevel))
        ..addData(_selectedData);
    }

    final qrImage = QrImage(qr);

    _imageData = _getModules(qrImage);

    await _make();
  }

  Future _make() async {
    /// Define Image
    final size = (_imageData.length * _scale) + (_padding * _scale * 2);

    final image = img.Image(
      width: size,
      height: size,
    );

    // added padding
    final imageDataWithPadding = _addPadding();

    /// scale data
    final enlargedData = _MarticScaler<bool>()
        .scale(data: imageDataWithPadding, scaleFactor: _scale);

    for (int i = 0; i < enlargedData.length; i++) {
      final row = enlargedData[i];

      for (int j = 0; j < enlargedData.length; j++) {
        final d = row[j];

        if (d) {
          img.Color c = _convertMaterialColorToImageColor(_fgColor);

          image.setPixel(i, j, c);
        } else {
          image.setPixel(i, j, _convertMaterialColorToImageColor(_bgColor));
        }
      }
    }
    final png = img.encodePng(image);
    await File(_outputFilePath).writeAsBytes(png);
  }

  List<List<bool>> _addPadding() {
    List<List<bool>> out = [];

    for (int i = 0; i < _padding; i++) {
      final l = List.generate(_imageData.length + (_padding * 2), (_) => false);
      out.add(l);
    }

    for (final x in _imageData) {
      List<bool> myList = x;
      for (int i = 0; i < _padding; i++) {
        myList = [false, ...myList, false];
      }

      out.add(myList);
    }

    for (int i = 0; i < _padding; i++) {
      final l = List.generate(_imageData.length + (_padding * 2), (_) => false);
      out.add(l);
    }

    return out;
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

class _MarticScaler<T> {
  List<List<T>> scale({required List<List<T>> data, required int scaleFactor}) {
    _setInitialData(data, scaleFactor);
    _iterateOverRows();

    return output;
  }

  void _setInitialData(List<List<T>> data, int scale) {
    _initialData = data;
    _moduleCount = data.length;
    _scale = scale;
  }

  late List<List<T>> _initialData;

  late int _scale;

  late int _moduleCount;

  List<List<T>> output = [];

  void _iterateOverRows() {
    for (int i = 0; i < _moduleCount; i++) {
      final lis = _initialData[i];

      _fillRows(lis);
    }
  }

  void _fillRows(List list) {
    final List<List<T>> elementScaled = [];

    // Fill empty
    for (int s = 0; s < _scale; s++) {
      elementScaled.add([]);
    }

    // Fill row
    for (int i = 0; i < _scale; i++) {
      for (int j = 0; j < list.length; j++) {
        final k = List.generate(_scale, (_) => list[j]);
        for (final e in k) {
          elementScaled[i].add(e);
        }
      }
    }

    // Add row to output
    for (final element in elementScaled) {
      output.add(element);
    }
  }
}
