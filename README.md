Generate and save QR Code Image.

## Usage

```dart

  Future saveQRImage() async {
    String? outputDir = await FilePicker.platform.getDirectoryPath();
    if (outputDir == null) {
      return;
    }

    final generator = QRGenerator();

    await generator.generate(
      data: data,
      filePath: '$outputDir/hello.png',
      scale: 10,
    );
  }

```

The Image will get saved to the provided `filePath`.

### TODO

- [ ] Color Customization
- [ ] Add QR Code padding feature
- [ ] Add Logo
- [ ] Add Tests
