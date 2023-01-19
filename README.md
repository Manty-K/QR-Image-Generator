Generate and save QR Code Image.

<img src="https://i.ibb.co/8xg3fkg/demogif.gif" alt="Package usage demo"/>

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

- [ ] Add Transperency Support
- [ ] Write Documentation
- [ ] Add Image in Qr Code
- [ ] Add Tests
