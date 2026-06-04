import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_media_hub/services/image_service.dart';
import 'package:smart_media_hub/services/file_service.dart';
import 'package:smart_media_hub/services/storage_service.dart';
import 'package:smart_media_hub/theme/app_colors.dart';
import 'package:smart_media_hub/widgets/app_card.dart';
import 'package:smart_media_hub/widgets/gradient_button.dart';
import 'package:smart_media_hub/widgets/upload_area.dart';
import 'package:image/image.dart' as img;

class ProcessingParams {
  final Uint8List bytes;
  final String filter;
  final double brightness;
  final double contrast;
  final double saturation;
  final double rotation;
  final bool flipH;
  final bool flipV;
  final bool sharpen;
  final bool denoise;

  ProcessingParams({
    required this.bytes,
    required this.filter,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.rotation,
    required this.flipH,
    required this.flipV,
    required this.sharpen,
    required this.denoise,
  });
}

Uint8List runImageProcessing(ProcessingParams params) {
  final service = ImageService();
  img.Image? image = service.decode(params.bytes);
  if (image == null) return params.bytes;

  // 1. Rotation & Flip
  if (params.rotation != 0) image = service.rotate(image, params.rotation);
  if (params.flipH) image = service.flipHorizontal(image);
  if (params.flipV) image = service.flipVertical(image);

  // 2. Adjustments
  if (params.brightness != 1.0) image = service.adjustBrightness(image, params.brightness);
  if (params.contrast != 1.0) image = service.adjustContrast(image, params.contrast);
  if (params.saturation != 1.0) image = service.adjustSaturation(image, params.saturation);

  // 3. Filters
  switch (params.filter) {
    case "Vivid": image = service.colorBoost(image); break;
    case "Cool": image = service.coolFilter(image); break;
    case "Warm": image = service.warmFilter(image); break;
    case "B&W": image = service.grayscale(image); break;
    case "Vintage": image = service.sepia(image); break;
  }

  // 4. Effects
  if (params.sharpen) image = service.sharpen(image);
  if (params.denoise) image = service.denoise(image);

  return service.toJpg(image);
}

class ImageProcessingScreen extends StatefulWidget {
  const ImageProcessingScreen({super.key});

  @override
  State<ImageProcessingScreen> createState() => _ImageProcessingScreenState();
}

class _ImageProcessingScreenState extends State<ImageProcessingScreen> {
  Uint8List? _originalBytes;
  Uint8List? _previewBytes;
  String? _fileName;
  bool _isProcessing = false;
  
  final ImageService _imageService = ImageService();
  final FileService _fileService = FileService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  String _selectedFilter = "Original";
  double _brightness = 1.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _rotation = 0.0;
  bool _flipH = false;
  bool _flipV = false;
  bool _sharpen = false;
  bool _denoise = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _originalBytes = bytes;
        _previewBytes = bytes;
        _fileName = image.name;
        _resetState();
      });
    }
  }

  void _resetState() {
    _selectedFilter = "Original";
    _brightness = 1.0;
    _contrast = 1.0;
    _saturation = 1.0;
    _rotation = 0.0;
    _flipH = false;
    _flipV = false;
    _sharpen = false;
    _denoise = false;
  }

  void _triggerProcessing() async {
    if (_originalBytes == null) return;
    setState(() => _isProcessing = true);

    try {
      final params = ProcessingParams(
        bytes: _originalBytes!,
        filter: _selectedFilter,
        brightness: _brightness,
        contrast: _contrast,
        saturation: _saturation,
        rotation: _rotation,
        flipH: _flipH,
        flipV: _flipV,
        sharpen: _sharpen,
        denoise: _denoise,
      );

      final result = await compute(runImageProcessing, params);
      
      setState(() {
        _previewBytes = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Processing Error: $e")));
    }
  }

  Future<void> _saveResult(String format) async {
    if (_previewBytes == null) return;
    setState(() => _isProcessing = true);

    try {
      final image = _imageService.decode(_previewBytes!)!;
      Uint8List finalBytes;
      String ext;

      switch (format) {
        case "PNG": finalBytes = _imageService.toPng(image); ext = "png"; break;
        case "WebP": finalBytes = _imageService.toWebP(image); ext = "webp"; break;
        default: finalBytes = _imageService.toJpg(image); ext = "jpg";
      }

      final name = _fileService.generateFileName("hub_edit", ext);
      await _fileService.saveFile(finalBytes, name);
      
      await _storageService.saveToHistory(
        fileName: name,
        fileType: "Image",
        operation: "Image Edit ($format)",
        fileSize: finalBytes.length,
        downloadUrl: "local",
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved and added to history!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save Error: $e")));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Image Processing", style: Theme.of(context).textTheme.displayLarge),
              Text("Real-time creative photo tools", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 24),
              UploadArea(
                onTap: _pickImage,
                icon: Icons.upload_rounded,
                title: "Tap to select image",
                subtitle: "JPG PNG WebP supported",
                height: 300,
                preview: _previewBytes != null 
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(_previewBytes!, fit: BoxFit.contain, key: ValueKey(_previewBytes.hashCode)),
                        if (_isProcessing) 
                          Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator())),
                      ],
                    )
                  : null,
              ),
              if (_originalBytes != null)
                Center(
                  child: TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Change image", style: TextStyle(color: AppColors.purplePrimary)),
                  ),
                ),
              const SizedBox(height: 32),
              _sectionHeader("Filters"),
              const SizedBox(height: 12),
              _buildFilters(),
              const SizedBox(height: 32),
              _sectionHeader("Adjustments"),
              const SizedBox(height: 12),
              _buildAdjustments(),
              const SizedBox(height: 32),
              _sectionHeader("Quick Tools"),
              const SizedBox(height: 12),
              _buildQuickTools(),
              const SizedBox(height: 32),
              _sectionHeader("Export"),
              const SizedBox(height: 12),
              _buildExport(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(title, style: Theme.of(context).textTheme.headlineMedium);

  Widget _buildFilters() {
    final filters = ["Original", "Vivid", "Cool", "Warm", "B&W", "Vintage"];
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final f = filters[i];
          final sel = _selectedFilter == f;
          return GestureDetector(
            onTap: () { setState(() => _selectedFilter = f); _triggerProcessing(); },
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: AppColors.purplePink,
                      borderRadius: BorderRadius.circular(16),
                      border: sel ? Border.all(color: AppColors.purplePrimary, width: 3) : null,
                    ),
                    child: sel ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                  const SizedBox(height: 4),
                  Text(f, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdjustments() {
    return AppCard(
      child: Column(
        children: [
          _adjRow(Icons.brightness_6, "Brightness", _brightness, (v) { setState(() => _brightness = v); _triggerProcessing(); }),
          _adjRow(Icons.contrast, "Contrast", _contrast, (v) { setState(() => _contrast = v); _triggerProcessing(); }),
          _adjRow(Icons.palette, "Saturation", _saturation, (v) { setState(() => _saturation = v); _triggerProcessing(); }),
        ],
      ),
    );
  }

  Widget _adjRow(IconData icon, String label, double val, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.purplePrimary),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Expanded(flex: 2, child: Slider(value: val, min: 0.2, max: 2.0, onChanged: onChanged)),
        Text(val.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickTools() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _toolItem(Icons.rotate_right, "Rotate", () { setState(() => _rotation = (_rotation + 90) % 360); _triggerProcessing(); }),
        _toolItem(Icons.flip, "Flip H", () { setState(() => _flipH = !_flipH); _triggerProcessing(); }),
        _toolItem(Icons.flip_camera_android, "Flip V", () { setState(() => _flipV = !_flipV); _triggerProcessing(); }),
        _toolItem(Icons.auto_fix_high, "Sharpen", () { setState(() => _sharpen = !_sharpen); _triggerProcessing(); }, active: _sharpen),
        _toolItem(Icons.blur_on, "Denoise", () { setState(() => _denoise = !_denoise); _triggerProcessing(); }, active: _denoise),
      ],
    );
  }

  Widget _toolItem(IconData icon, String label, VoidCallback onTap, {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: EdgeInsets.zero,
        color: active ? AppColors.purplePrimary.withValues(alpha: 0.2) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: active ? AppColors.purplePrimary : null),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildExport() {
    return Row(
      children: [
        Expanded(child: GradientButton(text: "Save JPG", onPressed: () => _saveResult("JPG"), gradient: AppColors.purpleBlue, height: 45)),
        const SizedBox(width: 12),
        Expanded(child: OutlinedButton(onPressed: () => _saveResult("PNG"), child: const Text("PNG"))),
        const SizedBox(width: 12),
        Expanded(child: OutlinedButton(onPressed: () => _saveResult("WebP"), child: const Text("WebP"))),
      ],
    );
  }
}
