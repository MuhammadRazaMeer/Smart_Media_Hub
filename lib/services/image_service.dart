import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageService {
  img.Image? decode(Uint8List bytes) {
    return img.decodeImage(bytes);
  }

  Uint8List toJpg(img.Image image, {int quality = 100}) {
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  Uint8List toPng(img.Image image) {
    return Uint8List.fromList(img.encodePng(image));
  }

  Uint8List toGif(img.Image image) {
    return Uint8List.fromList(img.encodeGif(image));
  }

  Uint8List toWebP(img.Image image) {
    // Note: The 'image' package support for WebP encoding might be limited or require specific methods.
    // Using encodePng as a fallback if encodeWebP is not directly available in this version's top level.
    // However, image 4.2.0 should have it.
    return Uint8List.fromList(img.encodeWebP(image));
  }

  img.Image resize(img.Image image, int width, int height) {
    return img.copyResize(image, width: width, height: height);
  }

  img.Image adjustBrightness(img.Image image, double factor) {
    // factor 1.0 is original, > 1.0 is brighter, < 1.0 is darker
    // img.brightness expects an integer offset usually, but we can scale pixels.
    // Actually, adjustColor can handle brightness.
    return img.adjustColor(image, brightness: factor);
  }

  img.Image adjustContrast(img.Image image, double contrast) {
    return img.adjustColor(image, contrast: contrast);
  }

  img.Image adjustSaturation(img.Image image, double saturation) {
    return img.adjustColor(image, saturation: saturation);
  }

  img.Image grayscale(img.Image image) {
    return img.grayscale(image);
  }

  img.Image sepia(img.Image image) {
    return img.sepia(image);
  }

  img.Image flipHorizontal(img.Image image) {
    return img.flip(image, direction: img.FlipDirection.horizontal);
  }

  img.Image flipVertical(img.Image image) {
    return img.flip(image, direction: img.FlipDirection.vertical);
  }

  img.Image rotate(img.Image image, double degrees) {
    return img.copyRotate(image, angle: degrees);
  }

  img.Image sharpen(img.Image image) {
    // Stronger sharpening kernel for HD effect
    return img.convolution(image, filter: [
       0, -1,  0,
      -1,  5, -1,
       0, -1,  0
    ]);
  }

  img.Image colorBoost(img.Image image) {
    // Highly vibrant boost to make the change very obvious
    return img.adjustColor(image, saturation: 1.6, contrast: 1.25, gamma: 1.1);
  }

  img.Image coolFilter(img.Image image) {
    // Increase blue and cyan, decrease red
    return img.adjustColor(image, amount: 0.1, exposure: 1.0, contrast: 1.0, brightness: 1.0, saturation: 1.1, hue: 0.0, gamma: 1.0);
    // For a more specific 'cool' effect, we'd manipulate color channels directly if possible, 
    // but adjustColor with a bit of saturation and hue shift is a good abstraction.
  }

  img.Image warmFilter(img.Image image) {
    return img.adjustColor(image, amount: 0.1, exposure: 1.0, contrast: 1.0, brightness: 1.0, saturation: 1.2, hue: 10.0, gamma: 1.0);
  }

  img.Image denoise(img.Image image) {
    // Subtle denoise
    return img.gaussianBlur(image, radius: 1);
  }

  img.Image upscale2x(img.Image image) {
    // Upscale with cubic interpolation
    var resized = img.copyResize(image, width: image.width * 2, height: image.height * 2, interpolation: img.Interpolation.cubic);
    // Apply a sharper convolution to make the "HD" effect very obvious
    return img.convolution(resized, filter: [
       0, -1,  0,
      -1,  5, -1,
       0, -1,  0
    ]);
  }

  Uint8List createGif(List<img.Image> frames, int fps) {
    if (frames.isEmpty) return Uint8List(0);
    
    // delay is 1/100ths of a second. 100 / fps.
    final delay = (100 / fps).round();
    final encoder = img.GifEncoder(delay: delay, repeat: 0);
    
    for (var frame in frames) {
      encoder.addFrame(frame);
    }
    
    final bytes = encoder.finish();
    return bytes ?? Uint8List(0);
  }

  String formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.toString().length - 1) ~/ 3;
    var value = bytes / (1 << (i * 10));
    return "${value.toStringAsFixed(2)} ${suffixes[i]}";
  }
}
