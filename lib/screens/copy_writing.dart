import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_next_imagen_demo/utils/vertexai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';

class CopyWriting extends StatefulWidget {
  const CopyWriting({super.key});

  @override
  State<CopyWriting> createState() => _CopyWritingState();
}

class _CopyWritingState extends State<CopyWriting> {
  XFile? pickedImage;
  Uint8List? imageToRender;
  late TextEditingController _textController;

  String prompt = "あなたは世界で最も優秀な広告マーケターです。添付の画像に対する商品の広告文を提案してください。回答は広告文のみを返してください。";

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

  Future<void> _handleGenerate() async {
    String imageToSend = base64Encode(imageToRender!.toList());
    var copywriteResponse = await vertexai.CopyWriting(prompt, imageToSend);
    print (copywriteResponse.candidates[0].content.parts[0].text);

    setState(() {
      _textController.text = copywriteResponse.candidates[0].content.parts[0].text;
    });
  }

  Widget renderImage(image) {
    final screenSize = MediaQuery.of(context).size;
    final imageSize = screenSize.shortestSide * 0.75;

    if (image != null) {
      return  SizedBox(
                width: imageSize,
                height: imageSize,
                child:Image.memory(
                  image,
                  width: double.infinity,
                )
              );
    } else {
      return const Text("Try Gemini1.5 Flash Copywriting with your uploaded image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コピーライティング'),
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
                   MaterialButton(
                    onPressed: _handleGenerate,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(24), 
            child:
              Text(_textController.text)
            ),
          ],
        ),
      ),
    );
  }
}
