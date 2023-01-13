Generate and save QR Code Image.

### Packages Used

- [qr](https://pub.dev/packages/qr)
- [image](https://pub.dev/packages/image)

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
    );
  }

```

The Image will get saved to the provided `filePath`.

### TODO

- [ ] Write Documentation
- [ ] Add Logo
- [ ] Add Tests
