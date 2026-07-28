import 'dart:typed_data';
import 'dart:ui' as ui;

/// Output side length required by the server's strict allow-list PNG parser
/// (`validateAvatarPng` in `functions/src/feed/png.ts`): exactly 256x256.
const avatarEncodedDimension = 256;

/// Encodes arbitrary source image bytes (whatever `image_picker`/the OS photo
/// library handed back) into the exact PNG shape `validateAvatarPng` demands:
/// 256x256, 8-bit depth, colour type 6 (RGBA), no interlace. Modelled
/// directly on `encodePrivacyMaskedPng` in
/// `../../../you/presentation/widgets/activity_route_mapbox_snapshot_provider.dart` —
/// decode via `ui.instantiateImageCodec`, draw into a fixed-size canvas, then
/// re-encode via Skia's own `toByteData(format: ui.ImageByteFormat.png)`.
/// Skia's PNG encoder is what already guarantees the chunk allow-list
/// (`IHDR|cHRM|gAMA|sBIT|sRGB|IDAT|IEND`) with no unexpected ancillary
/// chunks — this function does not hand-construct any PNG bytes itself.
///
/// Unlike the route-snapshot pipeline (which draws into a fixed
/// caller-supplied aspect ratio), this centre-crops the largest centred
/// square out of the source first, so a landscape or portrait source is
/// never squashed/stretched — only cropped. The result is a square photo;
/// callers (the avatar disc widgets) clip it to a circle at render time, so
/// this module never draws a circle mask itself.
///
/// Every decoded [ui.Image] is disposed, including on the error path, so a
/// failed encode never leaks a Skia-side image.
Future<Uint8List> encodeAvatarPng(Uint8List sourceBytes) async {
  final codec = await ui.instantiateImageCodec(sourceBytes);
  final frame = await codec.getNextFrame();
  codec.dispose();
  final image = frame.image;
  try {
    final side = image.width < image.height ? image.width : image.height;
    final sourceRect = ui.Rect.fromLTWH(
      (image.width - side) / 2,
      (image.height - side) / 2,
      side.toDouble(),
      side.toDouble(),
    );
    final destinationRect = ui.Rect.fromLTWH(
      0,
      0,
      avatarEncodedDimension.toDouble(),
      avatarEncodedDimension.toDouble(),
    );
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      image,
      sourceRect,
      destinationRect,
      ui.Paint()
        ..isAntiAlias = true
        ..filterQuality = ui.FilterQuality.high,
    );
    final output = await recorder.endRecording().toImage(
      avatarEncodedDimension,
      avatarEncodedDimension,
    );
    try {
      final data = await output.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw StateError('Avatar PNG encoding was unavailable.');
      }
      return data.buffer.asUint8List();
    } finally {
      output.dispose();
    }
  } finally {
    image.dispose();
  }
}
