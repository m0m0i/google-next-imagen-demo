import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_next_imagen_demo/utils/error_dialog.dart';
import 'package:google_next_imagen_demo/utils/loading_indicator.dart';
import 'package:google_next_imagen_demo/utils/render_image_widget.dart';
import 'package:google_next_imagen_demo/utils/vertexai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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

  bool visibleBool = false;

  bool sendButtonActive = true;

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

  Future<void> handleGenerate(context, String prompt) async {
    setState(() {
      sendButtonActive = false;
    });

    await FirebaseAnalytics.instance
        .logEvent(name: 'Edit image', parameters: {"propmt": prompt});

    await Future.delayed(const Duration(milliseconds: 450));

    setState(() {
      visibleBool = true;
    });

    try {
      final generatedImage = await vertexai.editImage(prompt, imageToRender!);
      imageToRender =
          base64Decode(generatedImage.predictions[0].bytesBase64Encoded);
    } catch (e) {
      await FirebaseAnalytics.instance.logEvent(
          name: 'Edit image failed',
          parameters: {"propmt": prompt, "error": "$e"});

      showErrorDialog(context, "リクエストに失敗しました");
    } finally {
      setState(() {
        sendButtonActive = true;
        visibleBool = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('イメージ編集'),
      ),
      body: Builder(
          builder: ((context) => Stack(children: [
                Column(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: imageToRender != null
                                      ? CustomImageWidget(context,
                                          imageData: imageToRender!)
                                      : const Text(
                                          "Try Imagen 2 image editing"),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: TextField(
                                  controller: _textController,
                                  minLines: 1,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: (sendButtonActive)
                                          ? () async {
                                              final prompt =
                                                  _textController.value.text;
                                              if (prompt != "" &&
                                                  pickedImage != null) {
                                                await handleGenerate(
                                                    context, prompt);
                                              }
                                            }
                                          : null,
                                      icon: const Icon(Icons.send),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 18,
                        child: Image.asset('images/logo_s.png'),
                      ),
                    )
                  ],
                ),
                OverlayProgressIndicator(visible: visibleBool)
              ]))),
    );
  }
}
