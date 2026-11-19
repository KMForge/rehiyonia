// Extract an existing JPEG stream from a source PDF without rasterizing a page.
// Usage: dart scripts/extract_pdf_photo.dart source.pdf object-id output.jpg
// Use "all" as object-id and an existing directory to inspect all JPEG photos.
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.length != 3) {
    throw ArgumentError('Expected PDF path, object ID (or all), output path');
  }
  final bytes = File(args[0]).readAsBytesSync();
  final source = latin1.decode(bytes);
  var extracted = 0;
  for (final object in RegExp(
    r'(\d+) 0 obj\s*([\s\S]*?)endobj',
  ).allMatches(source)) {
    final id = object[1]!;
    if (args[1] != 'all' && id != args[1]) {
      continue;
    }
    final stream = RegExp(r'stream\r?\n').firstMatch(object[2]!);
    if (stream == null) {
      continue;
    }
    final dictionary = object[2]!.substring(0, stream.start);
    if (!dictionary.contains('/Subtype /Image') ||
        !dictionary.contains('/DCTDecode')) {
      continue;
    }
    final length = int.parse(
      RegExp(r'/Length (\d+)\s').firstMatch(dictionary)![1]!,
    );
    final start = object.end - 'endobj'.length - object[2]!.length + stream.end;
    List<int> photo = bytes.sublist(start, start + length);
    if (dictionary.contains('/FlateDecode')) {
      photo = zlib.decode(photo);
    }
    if (photo.length < 4 || photo[0] != 255 || photo[1] != 216) {
      throw StateError('PDF object $id did not decode to JPEG');
    }
    final output = args[1] == 'all' ? '${args[2]}/pdf_image_$id.jpg' : args[2];
    File(output).writeAsBytesSync(photo);
    stdout.writeln('Extracted JPEG object $id (${photo.length} bytes)');
    extracted++;
  }
  if (extracted == 0) {
    throw StateError('Requested JPEG object not found');
  }
}
