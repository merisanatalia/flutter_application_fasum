import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class FullScreenImageScreen extends StatefulWidget {
  final String imageBase64;

  const FullScreenImageScreen({
    super.key,
    required this.imageBase64,
  });

  @override
  State<FullScreenImageScreen> createState() =>
      _FullScreenImageScreenState();
}

class _FullScreenImageScreenState
    extends State<FullScreenImageScreen> {
  bool _isSaving = false;

  Future<void> _saveImage() async {
    setState(() => _isSaving = true);

    try {
      final bytes = base64Decode(widget.imageBase64);

      if (kIsWeb) {
      final bytes = base64Decode(widget.imageBase64);

      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "image.png")
        ..click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download berhasil')),
      );

       return;
      }

      if (Theme.of(context).platform == TargetPlatform.android) {
        final status = await Permission.photos.request();

        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin ditolak')),
          );
          return;
        }
      }

      final name =
          'image_${DateTime.now().millisecondsSinceEpoch}';

      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: name,
      );

      final success =
          result['isSuccess'] == true || result['filePath'] != null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Berhasil disimpan ke galeri'
                : 'Gagal menyimpan',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = base64Decode(widget.imageBase64);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lihat Gambar'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.download),
            onPressed: _isSaving ? null : _saveImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: Center(
              child: InteractiveViewer(
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _isSaving ? null : _saveImage,
              child: const Icon(Icons.download),
            ),
          )
        ],
      ),
    );
  }
}