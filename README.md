Generate and save QR Code Image.

---

## Basic Usage

```dart

    final generator = QRGenerator();

    await generator.generate(
      data: 'Hello World!',
      filePath: '$outputDir/hello.png',
    );

```

## Full Usage

```dart

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
      foregroundColor: Colors.yellow,
      backgroundColor: Colors.blue,
      errorCorrectionLevel: ErrorCorrectionLevel.medium,
      qrVersion: 4,
    );
  }

```

The Image will get saved to the provided `filePath`.

---

### TODO

- [ ] Write Documentation
- [ ] Add Logo support
- [ ] Add Tests
