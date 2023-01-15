Generate and save QR Code Image.

---

### Packages Used

- [qr](https://pub.dev/packages/qr)
- [image](https://pub.dev/packages/image)
- [path_provider](https://pub.dev/packages/path_provider)

## Usage

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
    );
  }

```

The Image will get saved to the provided `filePath`.

---

### TODO

- [ ] Set QR Version
- [ ] Write Documentation
- [ ] Add Logo support
- [ ] Add Tests
