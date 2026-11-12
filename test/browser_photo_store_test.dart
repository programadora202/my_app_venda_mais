import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_venda_mais/browser_photo_store.dart';

void main() {
  test('browser photo can be saved, read and removed', () async {
    const key = 'browser-photo:integration-test';
    final bytes = Uint8List.fromList([0, 127, 255]);
    addTearDown(() => deleteBrowserPhoto(key));

    await saveBrowserPhoto(key, bytes);
    expect(await readBrowserPhoto(key), orderedEquals(bytes));

    await deleteBrowserPhoto(key);
    expect(await readBrowserPhoto(key), isNull);
  }, skip: !kIsWeb);
}
