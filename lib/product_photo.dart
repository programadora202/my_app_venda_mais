import 'dart:io';
import 'dart:typed_data';

import 'browser_photo_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const browserPhotoPrefix = 'browser-photo:';

bool isRemotePhoto(String path) => Uri.tryParse(path)?.scheme == 'https';

Widget productPhoto(
  String path, {
  required double width,
  required double height,
  required ImageErrorWidgetBuilder errorBuilder,
}) {
  if (path.startsWith(browserPhotoPrefix)) {
    return FutureBuilder<Uint8List?>(
      future: readBrowserPhoto(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(width: width, height: height);
        }
        final bytes = snapshot.data;
        if (bytes == null) {
          return SizedBox(
            width: width,
            height: height,
            child: errorBuilder(
              context,
              snapshot.error ?? StateError('Foto indisponível neste navegador'),
              snapshot.stackTrace,
            ),
          );
        }
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: errorBuilder,
        );
      },
    );
  }
  if (isRemotePhoto(path)) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: errorBuilder,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
    );
  }
  if (kIsWeb) {
    return SizedBox(
      width: width,
      height: height,
      child: Builder(
        builder: (context) =>
            errorBuilder(context, UnsupportedError('Foto local no navegador'), null),
      ),
    );
  }
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: errorBuilder,
  );
}

Future<void> deleteProductPhoto(String path) async {
  if (path.startsWith(browserPhotoPrefix)) {
    await deleteBrowserPhoto(path);
  } else if (!kIsWeb && !isRemotePhoto(path)) {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
