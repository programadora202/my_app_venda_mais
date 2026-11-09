import 'dart:typed_data';

Future<void> saveBrowserPhoto(String key, Uint8List bytes) async =>
    throw UnsupportedError('Armazenamento de fotos disponível apenas na web.');

Future<Uint8List?> readBrowserPhoto(String key) async => null;

Future<void> deleteBrowserPhoto(String key) async {}
