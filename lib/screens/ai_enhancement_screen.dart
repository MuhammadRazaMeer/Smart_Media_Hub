import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_media_hub/theme/app_colors.dart';
import 'package:smart_media_hub/widgets/app_card.dart';
import 'package:smart_media_hub/widgets/gradient_button.dart';
import 'package:smart_media_hub/services/image_service.dart';
import 'package:smart_media_hub/services/file_service.dart';
import 'package:smart_media_hub/services/storage_service.dart';
import 'package:image/image.dart' as img;

class EnhancementParams {
  final Uint8List bytes;
  final bool upscale;
  final bool denoise;
  final bool sharpen;
  final bool colorBoost;

  EnhancementParams({
    required this.bytes,
    required this.upscale,
    required this.denoise,
    required this.sharpen,
    required this.colorBoost,
  });
}

// Optimized processing function to prevent hangs
Uint8List processEnhancement(EnhancementParams params) {
  final service = ImageService();
  img.Image? image = service.decode(params.bytes);
  if (image == null) return params.bytes;

  // 1. Safety Limit: If image is too large, resize to manageable size (max 1500px)
  // This prevents memory crashes on mobile during heavy upscaling
  if (image.width > 1500 || image.height > 1500) {
    image = img.copyResize(image, width: image.width > image.height ? 1500 : null, height: image.height >= image.width ? 1500 : null);
  }

  // 2. Denoise (Before upscale to avoid enlarging noise)
  if (params.denoise) {
    image = img.gaussianBlur(image, radius: 1);
  }

  // 3. Upscale (Max 2x)
  if (params.upscale) {
    image = img.copyResize(image, width: image.width * 2, height: image.height * 2, interpolation: img.Interpolation.cubic);
  }

  // 4. Color & Contrast Boost
  if (params.colorBoost) {
    image = img.adjustColor(image, saturation: 1.4, contrast: 1.15, gamma: 1.05);
  }

  // 5. Final Sharpen (Last step for crisp edges)
  if (params.sharpen) {
    image = img.convolution(image, filter: [0, -1, 0, -1, 5, -1, 0, -1, 0]);
  }

  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

class AiEnhancementScreen extends StatefulWidget {
  const AiEnhancementScreen({super.key});

  @override
  State<AiEnhancementScreen> createState() => _AiEnhancementScreenState();
}

class _AiEnhancementScreenState extends State<AiEnhancementScreen> {
  Uint8List? _originalImage;
  Uint8List? _enhancedImage;
  bool _showEnhanced = false;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  final FileService _fileService = FileService();
  final StorageService _storageService = StorageService();

  bool _upscale = true;
  bool _denoise = true;
  bool _sharpen = true;
  bool _colorBoost = true;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _originalImage = bytes;
        _enhancedImage = null;
        _showEnhanced = false;
      });
    }
  }

  void _enhance() async {
    if (_originalImage == null) return;
    setState(() {
      _isProcessing = true;
      _showEnhanced = false;
    });

    try {
      final params = EnhancementParams(
        bytes: _originalImage!,
        upscale: _upscale,
        denoise: _denoise,
        sharpen: _sharpen,
        colorBoost: _colorBoost,
      );

      // Run in background isolate
      final result = await compute(processEnhancement, params);
      
      setState(() {
        _enhancedImage = result;
        _showEnhanced = true;
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("AI Enhancement Complete! ✨"), duration: Duration(seconds: 2)),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enhancement failed: $e")),
      );
    }
  }

  Future<void> _downloadImage() async {
    if (_enhancedImage == null) return;
    setState(() => _isProcessing = true);
    try {
      final fileName = _fileService.generateFileName("ai_enhanced", "jpg");
      await _fileService.saveFile(_enhancedImage!, fileName);
      
      await _storageService.saveToHistory(
        fileName: fileName,
        fileType: "Image",
        operation: "AI Enhancement",
        fileSize: _enhancedImage!.length,
        downloadUrl: "local",
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enhanced image saved!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save failed: $e")));
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(gradient: AppColors.purplePink, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.auto_fix_high_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text("AI Enhancement", style: Theme.of(context).textTheme.displayLarge),
                ],
              ),
              const SizedBox(height: 8),
              Text("Neural-powered media super-resolution", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 24),
              AppCard(
                color: AppColors.purplePrimary.withValues(alpha: 0.12),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: AppColors.purplePrimary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("AI HD Optimizer", style: Theme.of(context).textTheme.headlineMedium),
                          const Text("Processes images using background isolates for zero-lag UI.", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _toggleBtn("Original", !_showEnhanced, () => setState(() => _showEnhanced = false))),
                  const SizedBox(width: 12),
                  Expanded(child: _toggleBtn("Enhanced", _showEnhanced, () => setState(() => _showEnhanced = true))),
                ],
              ),
              const SizedBox(height: 16),
              _buildPreview(),
              const SizedBox(height: 32),
              Text("Enhancement Settings", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              _optionCard(Icons.hd, "HD Super Resolution", _upscale, (v) => setState(() => _upscale = v)),
              const SizedBox(height: 8),
              _optionCard(Icons.blur_on, "Noise Reduction", _denoise, (v) => setState(() => _denoise = v)),
              const SizedBox(height: 8),
              _optionCard(Icons.deblur, "Edge Sharpening", _sharpen, (v) => setState(() => _sharpen = v)),
              const SizedBox(height: 8),
              _optionCard(Icons.palette, "Color Intelligence", _colorBoost, (v) => setState(() => _colorBoost = v)),
              const SizedBox(height: 32),
              GradientButton(
                text: _isProcessing ? "Enhancing..." : "Enhance Image ✨",
                onPressed: _originalImage != null && !_isProcessing ? _enhance : null,
                gradient: AppColors.purplePink,
                isLoading: _isProcessing,
              ),
              if (_enhancedImage != null && !_isProcessing) ...[
                const SizedBox(height: 16),
                GradientButton(
                  text: "Save HD Result 📥",
                  onPressed: _downloadImage,
                  gradient: AppColors.blueCyan,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.purplePrimary : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : Colors.grey[200]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: active ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return GestureDetector(
      onTap: _pickImage,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: _originalImage == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.purplePrimary),
                    SizedBox(height: 12),
                    Text("Select image to optimize"),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      _showEnhanced && _enhancedImage != null ? _enhancedImage! : _originalImage!, 
                      fit: BoxFit.contain,
                      key: ValueKey(_showEnhanced ? (_enhancedImage?.hashCode ?? 0) : (_originalImage?.hashCode ?? 1)),
                    ),
                    if (_isProcessing)
                      Container(
                        color: Colors.black54,
                        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: Text(_showEnhanced ? "HD RESULT ✨" : "ORIGINAL", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _optionCard(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? AppColors.purplePrimary.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: value ? AppColors.purplePrimary : Colors.grey, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.purplePrimary),
        ],
      ),
    );
  }
}
