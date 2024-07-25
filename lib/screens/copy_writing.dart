import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:formatted_text/formatted_text.dart';
import 'package:google_next_imagen_demo/utils/error_dialog.dart';
import 'package:google_next_imagen_demo/utils/loading_indicator.dart';
import 'package:google_next_imagen_demo/utils/render_image_widget.dart';
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

  bool visibleBool = false;

  String prompt =
      "あなたは世界で最も優秀な広告マーケターです。添付の画像に対する商品の広告文を提案してください。回答は200文字以内でタイトルと広告文を返してください。なお、タイトルは太字にしてください。";

  final vertexai = VertexAI();

  @override
  void initState() {
    super.initState();
    _textController = FormattedTextEditingController();
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

    setState(() {
      visibleBool = true;
    });

    try {
      var copywriteResponse = await vertexai.copyWriting(prompt, imageToSend);
      debugPrint(copywriteResponse.candidates[0].content.parts[0].text);
      _textController.text =
          copywriteResponse.candidates[0].content.parts[0].text;
    } catch (e) {
      showErrorDialog(context, "リクエストに失敗しました");
    } finally {
      setState(() {
        visibleBool = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コピーライティング'),
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
                                child: imageToRender != null
                                    ? CustomImageWidget(context,
                                        imageData: imageToRender!)
                                    : const Text("Try Gemini Copywriting"),
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
                                    MaterialButton(
                                      onPressed: _handleGenerate,
                                      child: const Icon(Icons.send),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: FormattedText(
                                  _textController.text,
                                  formatters: const [
                                    ...FormattedTextDefaults
                                        .formattedTextDefaultFormatters,
                                    FormattedTextFormatter(
                                        patternChars: '**',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              )
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
