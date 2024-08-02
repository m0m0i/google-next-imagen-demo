import 'dart:convert';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

class DefaultCustomImageWidget extends StatelessWidget {
  final Uint8List imageData;

  final double imageSize;

  const DefaultCustomImageWidget(BuildContext context,
      {super.key, required this.imageData, required this.imageSize});

  @override
  Widget build(BuildContext context) {
    // バイナリデータをBase64エンコード
    String base64Image = base64Encode(imageData);
    String imageUrl = 'data:image/png;base64,$base64Image';

    // Create a DOM element with the img tag
    final web.HTMLImageElement imageElement = web.HTMLImageElement()
      ..style.width = 'auto'
      ..style.height = '100%';
    imageElement.src = imageUrl;

    // Register the DOM element as a view
    final String viewId = 'custom-image-${imageData.hashCode}';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory(viewId, (int viewId) => imageElement);

    // Return a HtmlElementView that displays the registered DOM element
    return SizedBox(
      width: imageSize,
      height: imageSize,
      child: HtmlElementView(viewType: viewId),
    );
  }
}
