//import 'dart:io';

import 'dart:html';
import 'dart:typed_data';

void download(String filename, Uint8List data, {String type = 'octet/stream'}) {
  final blob = Blob([data], type);
  final url = Url.createObjectUrlFromBlob(blob);

  final a = AnchorElement()
    ..style.display = 'none'
    ..href = url
    ..download = filename;

  document.body.append(a);

  a.click();
  Url.revokeObjectUrl(url);

  a.remove();
}

