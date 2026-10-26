import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class KidListoStickers {
  KidListoStickers._();

  static const assets = <String>[
    'assets/stickers/kid-listo/1.png',
    'assets/stickers/kid-listo/2.png',
    'assets/stickers/kid-listo/3.png',
    'assets/stickers/kid-listo/4.png',
    'assets/stickers/kid-listo/5.png',
    'assets/stickers/kid-listo/6.png',
    'assets/stickers/kid-listo/7.png',
    'assets/stickers/kid-listo/8.png',
    'assets/stickers/kid-listo/9.png',
    'assets/stickers/kid-listo/10.png',
    'assets/stickers/kid-listo/11.png',
    'assets/stickers/kid-listo/12.png',
  ];

  static Future<File> fileFromAsset(String asset) async {
    final data = await rootBundle.load(asset);
    final dir = await getTemporaryDirectory();
    final name = asset.split('/').last;
    final file = File('${dir.path}/kid-listo-sticker-$name');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file;
  }
}

class CommentComposerPick {
  const CommentComposerPick.emoji(this.emoji) : stickerAsset = null;

  const CommentComposerPick.sticker(this.stickerAsset) : emoji = null;

  final String? emoji;
  final String? stickerAsset;
}
