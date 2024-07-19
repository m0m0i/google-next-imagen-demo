import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_next_imagen_demo/utils/vertexai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';

class EditImage extends StatefulWidget {
  const EditImage({super.key});

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  XFile? pickedImage;
  Uint8List? imageToRender;
  late TextEditingController _textController;

  final vertexai = VertexAI();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  final ImagePickerPlugin _picker = ImagePickerPlugin();

  Future<void> _handlePickImageFromCamera() async {
    pickedImage = await _picker.getImageFromSource(source: ImageSource.camera);
    imageToRender = await pickedImage?.readAsBytes();

    setState(() {});
  }

  Future<void> _handlePickImageFromGallery() async {
    pickedImage = await _picker.getImageFromSource(source: ImageSource.gallery);
    imageToRender = await pickedImage?.readAsBytes();

    setState(() {});
  }

  Future<void> handleGenerate(String prompt) async {
    final generatedImage = await vertexai.editImage(prompt, imageToRender!);

    setState(() {
      imageToRender =
          base64Decode(generatedImage.predictions[0].bytesBase64Encoded);
    });
  }

  Widget renderImage(image) {
    if (image != null) {
      return Image.memory(
        image,
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: renderImage(imageToRender),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 2,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () async {
                      final prompt = _textController.value.text;
                      if (prompt != "" && pickedImage != null) {
                        await handleGenerate(prompt);
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed: _handlePickImageFromCamera,
                    child: const Icon(Icons.photo_camera),
                  ),
                  MaterialButton(
                    onPressed: _handlePickImageFromGallery,
                    child: const Icon(Icons.folder),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
