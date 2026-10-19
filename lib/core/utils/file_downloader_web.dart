import 'dart:js_interop';

import 'package:web/web.dart' as web;

void downloadTextFile({
  required String content,
  required String fileName,
  required String mimeType,
}) {
  final parts = <web.BlobPart>[content.toJS].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
