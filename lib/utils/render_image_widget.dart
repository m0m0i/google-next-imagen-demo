import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final Uint8List imageData;

  const CustomImageWidget(BuildContext context,
      {super.key, required this.imageData});

  @override
  Widget build(BuildContext context) {
    // バイナリデータをBase64エンコード
    String base64Image = base64Encode(imageData);
    String imageUrl = 'data:image/png;base64,$base64Image';
    final screenSize = MediaQuery.of(context).size;
    final imageSize = screenSize.shortestSide * 0.7;

    // Create a DOM element with the img tag
    final html.ImageElement imageElement = html.ImageElement(src: imageUrl)
      ..style.width = '100%'
      ..style.height = 'auto';

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
