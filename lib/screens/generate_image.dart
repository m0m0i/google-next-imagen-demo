import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_next_imagen_demo/utils/error_dialog.dart';
import 'package:google_next_imagen_demo/utils/loading_indicator.dart';
import 'package:google_next_imagen_demo/utils/render_image_widget.dart';
import 'package:google_next_imagen_demo/utils/vertexai.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class GenerateImage extends StatefulWidget {
  const GenerateImage({super.key});

  @override
  State<GenerateImage> createState() => _GenerateImageState();
}

class _GenerateImageState extends State<GenerateImage> {
  Uint8List? image;
  late TextEditingController textController;
  String sampleText = "";
  String sampleTextLabel = "";

  final vertexai = VertexAI();

  bool visibleBool = false;

  bool sendButtonActive = true;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> handleGenerate(context, prompt) async {
    setState(() {
      sendButtonActive = false;
    });

    await FirebaseAnalytics.instance
        .logEvent(name: 'Generate image', parameters: {"propmt": prompt});

    await Future.delayed(const Duration(milliseconds: 450));

    setState(() {
      visibleBool = true;
    });

    try {
      final generatedImage = await vertexai.generateImage(prompt);
      image = base64Decode(generatedImage.predictions[0].bytesBase64Encoded);
    } catch (e) {
      await FirebaseAnalytics.instance.logEvent(
          name: 'Generate image failed',
          parameters: {"propmt": prompt, "error": "$e"});
      showErrorDialog(context, "リクエストに失敗しました");
    } finally {
      setState(() {
        sendButtonActive = true;
        visibleBool = false;
      });
    }
  }

  Widget generateSampleText() {
    Random random = Random();

    List<String> sampleTextList = [
      "「Next Toyko」と書かれた青いビン、晴れた砂浜、ポートレート",
      "ふわふわの可愛いコアラ、眠っている、森の背景、プロカメラマンの写真",
      "上から見た本、一番上の本には水彩の鳥のイラスト、本には「VertexAI」と書かれている",
      "パスタディナーの頭上からの撮影、フード雑誌の表紙スタイルのスタジオ写真",
      "モダンなアームチェア、スタジオ写真、ドラマチックな照明",
      "水たまりに映る登山用リュックサック、背景に大きな山、ドラマチックなアングル",
    ];

    sampleText = sampleTextList[random.nextInt(sampleTextList.length)];
    sampleTextLabel = "例：$sampleText";

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        )),
        onPressed: () {
          textController.text = sampleText;
        },
        child: Text(
          sampleTextLabel,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
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
                              generateSampleText(),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: TextField(
                                  controller: textController,
                                  minLines: 1,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: (sendButtonActive)
                                          ? () async {
                                              final prompt =
                                                  textController.value.text;
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
