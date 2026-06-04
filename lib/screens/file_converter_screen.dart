import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smart_media_hub/theme/app_colors.dart';
import 'package:smart_media_hub/widgets/app_card.dart';
import 'package:smart_media_hub/widgets/gradient_button.dart';
import 'package:smart_media_hub/widgets/upload_area.dart';
import 'package:smart_media_hub/services/image_service.dart';
import 'package:smart_media_hub/services/file_service.dart';
import 'package:smart_media_hub/services/storage_service.dart';
import 'package:image/image.dart' as img;

class FileConverterScreen extends StatefulWidget {
  const FileConverterScreen({super.key});

  @override
  State<FileConverterScreen> createState() => _FileConverterScreenState();
}

class _FileConverterScreenState extends State<FileConverterScreen> {
  PlatformFile? _selectedFile;
  String _targetFormat = "JPG";
  double _quality = 90;
  bool _isProcessing = false;
  
  final ImageService _imageService = ImageService();
  final FileService _fileService = FileService();
  final StorageService _storageService = StorageService();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _convert() async {
    if (_selectedFile == null) return;
    setState(() => _isProcessing = true);

    try {
      final bytes = _selectedFile!.bytes ?? await _file_read_fallback(_selectedFile!);
      img.Image? image = _imageService.decode(bytes);
      
      if (image == null) throw Exception("Failed to decode image");

      Uint8List resultBytes;
      String extension;

      switch (_targetFormat) {
        case "PNG":
          resultBytes = _imageService.toPng(image);
          extension = "png";
          break;
        case "WebP":
          resultBytes = _imageService.toWebP(image);
          extension = "webp";
          break;
        case "GIF":
          resultBytes = _imageService.toGif(image);
          extension = "gif";
          break;
        default:
          resultBytes = _imageService.toJpg(image, quality: _quality.toInt());
          extension = "jpg";
      }

      final fileName = _fileService.generateFileName("converted", extension);
      await _fileService.saveFile(resultBytes, fileName);
      
      await _storageService.saveToHistory(
        fileName: fileName,
        fileType: "Converted File",
        operation: "Conversion to $_targetFormat",
        fileSize: resultBytes.length,
        downloadUrl: "local",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Converted to $_targetFormat and saved successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Conversion failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<Uint8List> _file_read_fallback(PlatformFile file) async {
    // On some platforms bytes might be null, usually we'd use path but we are restricted to kIsWeb check and file_service
    // Since we can't use dart:io, we assume web or mobile with bytes available or handled via file_picker
    if (file.bytes != null) return file.bytes!;
    // For mobile, we might need a workaround if bytes is null, but usually pickFiles returns bytes if configured or on web.
    throw Exception("File bytes not available");
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
              Text("File Converter", style: Theme.of(context).textTheme.displayLarge),
              Text("Convert media between formats instantly", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 24),
              UploadArea(
                onTap: _pickFile,
                icon: Icons.upload_file_outlined,
                title: _selectedFile == null ? "Tap to select file" : _selectedFile!.name,
                subtitle: _selectedFile == null ? null : "${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB",
                height: 160,
                preview: _selectedFile != null ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.green, size: 48),
                    const SizedBox(height: 12),
                    Text(_selectedFile!.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    Text("${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB", style: Theme.of(context).textTheme.labelSmall),
                  ],
                ) : null,
              ),
              const SizedBox(height: 32),
              Text("Quick Conversions", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.4,
                children: [
                  _quickConversionCard("PNG", "JPG", AppColors.blueCyan),
                  _quickConversionCard("JPG", "PNG", AppColors.purplePink),
                  _quickConversionCard("JPG", "WebP", AppColors.orangeRed),
                  _quickConversionCard("PNG", "GIF", AppColors.greenBlue),
                ],
              ),
              const SizedBox(height: 32),
              Text("Convert To", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ["JPG", "PNG", "WebP", "GIF"].map((f) => ChoiceChip(
                  label: Text(f),
                  selected: _targetFormat == f,
                  onSelected: (selected) => setState(() => _targetFormat = f),
                  selectedColor: AppColors.purplePrimary,
                  labelStyle: TextStyle(color: _targetFormat == f ? Colors.white : Colors.black),
                )).toList(),
              ),
              if (_targetFormat == "JPG") ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text("Quality"),
                    const Spacer(),
                    Text("${_quality.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.purplePrimary)),
                  ],
                ),
                Slider(value: _quality, min: 10, max: 100, onChanged: (v) => setState(() => _quality = v)),
              ],
              const SizedBox(height: 48),
              GradientButton(
                text: "Convert & Download",
                onPressed: _selectedFile != null && !_isProcessing ? _convert : null,
                gradient: AppColors.orangeRed,
                isLoading: _isProcessing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickConversionCard(String from, String to, Gradient gradient) {
    return GestureDetector(
      onTap: () => setState(() => _targetFormat = to),
      child: AppCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.swap_horiz, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text("$from ➔ $to", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
