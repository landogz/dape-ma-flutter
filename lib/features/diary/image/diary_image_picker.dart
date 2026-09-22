import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'diary_image_optimizer.dart';

/// Picks a journal photo from camera or gallery, then optimizes it.
class DiaryImagePicker {
  DiaryImagePicker._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pick({
    required BuildContext context,
    required String title,
    required String cameraLabel,
    required String galleryLabel,
    required String cancelLabel,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(cameraLabel),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(galleryLabel),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(cancelLabel),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return null;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 88,
    );
    if (picked == null) return null;

    return DiaryImageOptimizer.optimize(File(picked.path));
  }
}
