import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Output side length required by the server's strict allow-list PNG parser
/// (`validateAvatarPng` in `functions/src/feed/png.ts`): exactly 256x256.
const avatarEncodedDimension = 256;

/// Encodes arbitrary source image bytes (whatever `image_picker`/the OS photo
/// library handed back) into the exact PNG shape `validateAvatarPng` demands:
/// 256x256, colour type 6 (RGBA), no interlace, and either 8-bit depth or —
/// on a wide-gamut (Display P3) device, where Flutter renders into an F16
/// surface and Skia therefore emits depth 16 with `sBIT` 10,10,10,10 — that
/// wide-gamut shape. Both are accepted server-side; [_narrowToEightBitPng]
/// below tries to bring the wide-gamut case down to 8 bits because the same
/// photo costs roughly 290 KB at depth 16 against roughly 80 KB at depth 8,
/// paid on every leaderboard/feed/friends row that renders the avatar.
/// Modelled
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
      return await _narrowToEightBitPng(output) ?? await _encodePng(output);
    } finally {
      output.dispose();
    }
  } finally {
    image.dispose();
  }
}

/// Re-encodes [image] as an 8-bit-per-channel PNG by round-tripping its
/// pixels through raw RGBA, or returns null when that cannot be done — in
/// which case [encodeAvatarPng] falls back to encoding [image] directly and
/// behaves exactly as it did before this optimisation existed.
///
/// The bit depth of a directly encoded PNG is not a choice the encoder makes:
/// it follows the surface Flutter rendered into, and on a wide-gamut (Display
/// P3) device — every recent iPhone — that surface is F16, so Skia emits depth
/// 16. `ui.ImageByteFormat.rawRgba` reads those pixels back as 8-bit
/// premultiplied RGBA, and [ui.decodeImageFromPixels] rebuilds an image from
/// them at an explicitly 8-bit pixel format, so encoding THAT image yields
/// depth 8. The narrowing is real and intended: colours outside sRGB are
/// clamped, which is invisible at the ~40 logical-pixel discs these avatars
/// render into and is what buys the roughly 3-4x size reduction.
///
/// Returning null rather than throwing is deliberate. This is purely a size
/// optimisation on a path the server accepts either way, so every failure mode
/// — a null readback, a null re-encode, or a platform where the round-trip
/// does not actually narrow the depth — must degrade to the previous
/// behaviour instead of failing the user's upload. The result is accepted only
/// after confirming it really is depth 8, so a platform that quietly keeps 16
/// bits through the round-trip costs one wasted encode, never a regression.
Future<Uint8List?> _narrowToEightBitPng(ui.Image image) async {
  final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (raw == null) return null;
  final narrowed = await _imageFromPremultipliedRgba8888(
    raw.buffer.asUint8List(raw.offsetInBytes, raw.lengthInBytes),
    image.width,
    image.height,
  );
  try {
    final encoded = await _encodePngOrNull(narrowed);
    if (encoded == null || !_isEightBitPng(encoded)) return null;
    return encoded;
  } finally {
    narrowed.dispose();
  }
}

/// Wraps [ui.decodeImageFromPixels] — whose callback form owns the buffer and
/// descriptor disposal contract — as a future. [pixels] must be premultiplied,
/// which is exactly what `ui.ImageByteFormat.rawRgba` produces.
Future<ui.Image> _imageFromPremultipliedRgba8888(
  Uint8List pixels,
  int width,
  int height,
) {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels,
    width,
    height,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  return completer.future;
}

Future<Uint8List> _encodePng(ui.Image image) async {
  final encoded = await _encodePngOrNull(image);
  if (encoded == null) {
    throw StateError('Avatar PNG encoding was unavailable.');
  }
  return encoded;
}

Future<Uint8List?> _encodePngOrNull(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  if (data == null) return null;
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

/// True when [bytes] is a PNG whose IHDR declares bit depth 8. Reads only the
/// signature and the fixed-offset IHDR field, because IHDR is required by the
/// PNG spec to be the first chunk: 8 signature bytes, then a 4-byte length, a
/// 4-byte type, then width, height, and the bit depth at byte 24.
bool _isEightBitPng(Uint8List bytes) {
  const signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
  if (bytes.length < 25) return false;
  for (var index = 0; index < signature.length; index++) {
    if (bytes[index] != signature[index]) return false;
  }
  return bytes[12] == 0x49 &&
      bytes[13] == 0x48 &&
      bytes[14] == 0x44 &&
      bytes[15] == 0x52 &&
      bytes[24] == 8;
}
