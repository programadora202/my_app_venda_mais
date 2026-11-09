import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

const _store = 'photos';
Future<web.IDBDatabase>? _opening;

Future<web.IDBDatabase> _open() async {
  final ready = Completer<web.IDBDatabase>();
  final request = web.window.indexedDB.open('venda-mais', 1);
  request.onupgradeneeded = ((web.Event _) {
    (request.result as web.IDBDatabase).createObjectStore(_store);
  }).toJS;
  request.onsuccess = ((web.Event _) {
    ready.complete(request.result as web.IDBDatabase);
  }).toJS;
  request.onerror = ((web.Event _) {
    ready.completeError(StateError('Não foi possível abrir o cache de fotos.'));
  }).toJS;
  return ready.future;
}

Future<JSAny?> _request(
  String mode,
  web.IDBRequest Function(web.IDBObjectStore) action,
) async {
  final database = await (_opening ??= _open());
  final transaction = database.transaction(_store.toJS, mode);
  final result = Completer<JSAny?>();
  final request = action(transaction.objectStore(_store));
  transaction.oncomplete = ((web.Event _) {
    result.complete(request.result);
  }).toJS;
  transaction.onabort = ((web.Event _) {
    result.completeError(StateError(
      'Não foi possível acessar as fotos do navegador. '
      'Verifique se há espaço disponível.',
    ));
  }).toJS;
  return result.future;
}

Future<void> saveBrowserPhoto(String key, Uint8List bytes) async {
  await _request('readwrite', (store) => store.put(bytes.toJS, key.toJS));
}

Future<Uint8List?> readBrowserPhoto(String key) async {
  final result = await _request('readonly', (store) => store.get(key.toJS));
  return (result as JSUint8Array?)?.toDart;
}

Future<void> deleteBrowserPhoto(String key) async {
  await _request('readwrite', (store) => store.delete(key.toJS));
}
