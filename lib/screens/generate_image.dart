import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_next_imagen_demo/utils/vertexai.dart';

class GenerateImage extends StatefulWidget {
  const GenerateImage({super.key});

  @override
  State<GenerateImage> createState() => _GenerateImageState();
}

class _GenerateImageState extends State<GenerateImage> {
  var image = '';

  final vertexai = VertexAI();

  Future<void> handleGenerate() async {
    final generatedImage = await vertexai.generateImage();

    setState(() {
      image = generatedImage.predictions[0].bytesBase64Encoded;
    });
  }

  Widget renderImage(image) {
    if (image != '') {
      return Image.memory(
        base64Decode(image),
        width: 700,
        height: 700,
      );
    } else {
      return const Text("Try Imagen 3 image generation");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('イメージ生成'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            renderImage(image),
            const Padding(
              padding: EdgeInsets.all(8),
            ),
            ElevatedButton(
              onPressed: () async {
                await handleGenerate();
              },
              child: const Text('GENERATE'),
            ),
          ],
        ),
      ),
    );
  }
}
