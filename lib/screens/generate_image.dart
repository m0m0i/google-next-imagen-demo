import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_next_imagen_demo/utils/error_dialog.dart';
import 'package:google_next_imagen_demo/utils/loading_indicator.dart';
import 'package:google_next_imagen_demo/utils/render_image_widget.dart';
import 'package:google_next_imagen_demo/utils/vertexai.dart';

class GenerateImage extends StatefulWidget {
  const GenerateImage({super.key});

  @override
  State<GenerateImage> createState() => _GenerateImageState();
}

class _GenerateImageState extends State<GenerateImage> {
  Uint8List? image;
  late TextEditingController _controller;

  final vertexai = VertexAI();

  bool visibleBool = false;

  bool sendButtonActive = true;

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

  Future<void> handleGenerate(context, prompt) async {
    setState(() {
      sendButtonActive = false;
    });

    await Future.delayed(const Duration(milliseconds: 450));

    setState(() {
      visibleBool = true;
    });

    try {
      final generatedImage = await vertexai.generateImage(prompt);
      image = base64Decode(generatedImage.predictions[0].bytesBase64Encoded);
    } catch (e) {
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
        title: const Text('イメージ生成'),
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
                                child: image != null
                                    ? CustomImageWidget(context,
                                        imageData: image!)
                                    : const Text(
                                        "Try Imagen 3 image generation"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: TextField(
                                  controller: _controller,
                                  minLines: 1,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: (sendButtonActive)
                                          ? () async {
                                              final prompt =
                                                  _controller.value.text;
                                              if (prompt != "") {
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
