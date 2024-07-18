import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_next_imagen_demo/utils/vertexai.dart';

class EditImage extends StatefulWidget {
  const EditImage({super.key});

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  var image = '';
  late TextEditingController _controller;

  final vertexai = VertexAI();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> handleGenerate(prompt, image) async {
    final generatedImage = await vertexai.editImage(prompt, image);

    setState(() {
      image = generatedImage.predictions[0].bytesBase64Encoded;
    });
  }

  Widget renderImage(image) {
    if (image != '') {
      return Image.memory(
        base64Decode(image),
        width: double.infinity,
      );
    } else {
      return const Text("Try Imagen 2 image editing");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('イメージ編集'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // renderImage(image),
            Padding(
              padding: const EdgeInsets.all(24),
              child: renderImage(image),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 2,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () async {
                      final prompt = _controller.value.text;
                      if (prompt != "") await handleGenerate(prompt, "image");
                    },
                    icon: const Icon(Icons.send),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
