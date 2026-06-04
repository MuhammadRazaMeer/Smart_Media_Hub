import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_media_hub/theme/app_colors.dart';
import 'package:smart_media_hub/widgets/app_card.dart';
import 'package:smart_media_hub/widgets/gradient_button.dart';
import 'package:smart_media_hub/widgets/upload_area.dart';
import 'package:smart_media_hub/services/image_service.dart';
import 'package:smart_media_hub/services/file_service.dart';
import 'package:smart_media_hub/services/storage_service.dart';
import 'package:image/image.dart' as img;

class GifMakerScreen extends StatefulWidget {
  const GifMakerScreen({super.key});

  @override
  State<GifMakerScreen> createState() => _GifMakerScreenState();
}

class _GifMakerScreenState extends State<GifMakerScreen> {
  List<Uint8List> _frames = [];
  Uint8List? _gifBytes;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  final ImageService _imageService = ImageService();
  final FileService _fileService = FileService();
  final StorageService _storageService = StorageService();

  double _fps = 10;
  double _sizeFactor = 2; // 1:Small, 2:Medium, 3:Large
  bool _loop = true;

  Future<void> _pickFrames() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      List<Uint8List> bytes = [];
      for (var img in images) {
        bytes.add(await img.readAsBytes());
      }
      setState(() {
        _frames = bytes;
        _gifBytes = null;
      });
    }
  }

  Future<void> _createGif() async {
    if (_frames.isEmpty) return;
    setState(() => _isProcessing = true);

    try {
      List<img.Image> images = [];
      for (var frameBytes in _frames) {
        final decoded = _imageService.decode(frameBytes);
        if (decoded != null) {
          // Resize based on size factor
          int width = (decoded.width * (_sizeFactor / 2)).toInt();
          int height = (decoded.height * (_sizeFactor / 2)).toInt();
          images.add(_imageService.resize(decoded, width, height));
        }
      }

      if (images.isEmpty) throw Exception("Failed to decode frames");

      final result = _imageService.createGif(images, _fps.toInt());
      
      setState(() {
        _gifBytes = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("GIF creation failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _downloadGif() async {
    if (_gifBytes == null) return;
    setState(() => _isProcessing = true);

    try {
      final fileName = _fileService.generateFileName("animation", "gif");
      await _fileService.saveFile(_gifBytes!, fileName);
      
      await _storageService.saveToHistory(
        fileName: fileName,
        fileType: "GIF",
        operation: "GIF Creation",
        fileSize: _gifBytes!.length,
        downloadUrl: "local",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("GIF saved successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Save failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
              Text("GIF Maker", style: Theme.of(context).textTheme.displayLarge),
              Text("Create custom GIFs from images", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 24),
              UploadArea(
                onTap: _pickFrames,
                icon: Icons.collections_outlined,
                title: "Tap to select frames",
                height: 200,
                preview: _frames.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${_frames.length} frames selected", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _frames.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(image: MemoryImage(_frames[index]), fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: AppColors.purplePrimary,
                                        child: Text("${index + 1}", style: const TextStyle(fontSize: 10, color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
              if (_frames.isNotEmpty)
                Center(
                  child: TextButton(
                    onPressed: _pickFrames,
                    child: const Text("Change frames", style: TextStyle(color: AppColors.purplePrimary)),
                  ),
                ),
              const SizedBox(height: 32),
              if (_gifBytes != null) ...[
                _buildSection("GIF Preview"),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      Image.memory(_gifBytes!, gaplessPlayback: true),
                      const SizedBox(height: 8),
                      Text(_imageService.formatSize(_gifBytes!.length), style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
              _buildSection("Settings"),
              const SizedBox(height: 12),
              _buildSettings(),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _frames = [];
                        _gifBytes = null;
                      }),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text("Reset"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _gifBytes != null ? _downloadGif : null,
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text("Download GIF"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: "Create GIF 🎞️",
                onPressed: _frames.isNotEmpty && !_isProcessing ? _createGif : null,
                gradient: AppColors.greenBlue,
                isLoading: _isProcessing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineMedium);
  }

  Widget _buildSettings() {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              const Text("Frame Rate"),
              const Spacer(),
              Text("${_fps.toInt()} FPS", style: const TextStyle(color: AppColors.purplePrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(value: _fps, min: 5, max: 30, onChanged: (v) => setState(() => _fps = v)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("Size"),
              const Spacer(),
              Text(_sizeFactor == 1 ? "Small" : _sizeFactor == 2 ? "Medium" : "Large", style: const TextStyle(color: AppColors.purplePrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(value: _sizeFactor, min: 1, max: 3, divisions: 2, onChanged: (v) => setState(() => _sizeFactor = v)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("Loop Animation"),
              const Spacer(),
              Switch(value: _loop, onChanged: (v) => setState(() => _loop = v), activeColor: AppColors.purplePrimary),
            ],
          ),
        ],
      ),
    );
  }
}
