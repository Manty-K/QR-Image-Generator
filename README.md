Generate and save QR Code Image.

## Usage

```dart
void main() async {
	final  generator = QRGenerator();

	await generator.generate(
		data: 'Hello World!',
		filePath: 'hello.png',
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
