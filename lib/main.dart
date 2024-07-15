import "dart:async";
import "dart:convert";

import 'package:flutter/material.dart';
import "package:google_next_imagen_demo/models/imagen_resopnse.dart";

import "package:googleapis_auth/auth_io.dart";
import "package:http/http.dart" as http;

Future<AccessCredentials> obtainCredentials() async {
  var accountCredentials = ServiceAccountCredentials.fromJson({
    "private_key_id": "afcd88ffd8cd39cb530e2f0f8799e38f113a795b",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDWXnoRfEXGguF4\nutf1t5R70RFzBKvigqBKWkwGPW2F93wPFDMlJsUKdxygr74Jwub/4DnA8u4u8E7K\nn+7qb8zS51tAfSKFGzL9nozcQMbG7A8hJnCn7uiAKnP8OkyWZDwYYwimnCmV3b8c\nQ5sDTJu1b/qZ6Frg/lWgl8j+5kJFXQD2jdhrlZ8pRw6gBx6uf1FE2Ar08GM38ptc\nblM0NiVD14NTfVQ5lQawypipM5a74m7rAeuuWrIipgyOTkokyUYBuqrAYPundl/G\nqxH04wougSl/FQKwA5G3seoGAfuYtq0AhwpZ2X7SIaVBCBeURapPJlcGcZdux2xq\niy9WJ2djAgMBAAECggEADUCW9EjF+YEy1ida3XZlaAgjN4SU6bJgnWgaphIbGLqV\ngUsi5EuSx9RYQTjMG0dgx3XBrEN4ZQ93F4CuoPCbbXhfBEwYG7l0PAiWtbENeNO0\nFb0OHtuepPm65N9nx65XprxMlxw1V+32+BTX2urb/2n2SJh8MceXXI+1nch3VVlO\n/JLSzbV9KdFWQkwZKf9hgp2oSJPvec2PBX3w98m1QqkXDqKfLwdg/hY3oGjeEani\nEiLFoNAk1NIZYTTg0l+nyJLd7XtMZmFWi6RXNZ6V7NCsZIUzHBJf7OgiGKk7xV2A\nMSksOgpSqfrZ4dPg3oOuAutiflwgioxgbahQPXvM1QKBgQD92sY/r0n5zpA6qBuk\nos1S8dwgxk0OR8o9c8w+XE6ptQXJr4tHylMbKbd3/o4Ib9x5HcUvjRviyYKExHh4\nFDWSdLKhj4Xc6vKCE9b+mXYH4vhb0Qysh08yC0z4tsCTngwmKjmGFgdECUowV37q\nsuiSJpzOgogUhykIShWBKW/khQKBgQDYLkYSdlRfrADox6eFqnrk9HpjjGysDqSa\nP6SsspTc/+62yGSNzKSlxZ22seHGHsjoPzxOt5STk3bcWB1ot4x04xT1G2vjREGW\njUVxCJnuhiI1AlFG8gydItVqEmrsicQtQpTUZ0waeiRU7bilw0im4+xcxlhYv5BN\nUHdUZkb0xwKBgQDF8/C+PpGAJCziIK8VrgJQmNugDyKNbTvuubreMhsBSXEO+j2x\nKLuvpdM01iKpv5j8NVPLpczGB38oyxBqCtBPuYKGa6XmRKwA9Tmk5cRdmAc1ignJ\nC+aczqUiGViIhClTJYAf6FOYIWph0gjdOdAUD9odSzqUT2WW2jZ0tvxTBQKBgQCD\nDAoORwz+shYbBmzW6nF1OX63ufhmlLnTh6Ebz2XOUpcy1meeTd/BXfotNcfXgfHo\nV+0HCuJWU55KFGA/ioTqln2t1+Ge81GPIjRmQQCPR2CVIcKDb1eWKfeVRXTrztfN\nV/9Agx3vLvu3QCQe2DLCeIhf9Ry5L+cZ9x1fXGDHIQKBgQD650dBgPBbb8mfbxMF\nFxNt/FpTMUEhwkktrNPFGYjASBUpDFB6OkecN2Ccacqug0p4pVN2iqPtUCa0BUX+\ntXcquIWEeu0/rtsiULi4lbHIITIha3bZxd2l9n7/Le1oo2f69+zGRbP6nDNnEd+7\nxiugyTkmKRviaG/HmvET7ZuDbQ==\n-----END PRIVATE KEY-----\n",
    "client_email":
        "imagen-frontend@next-tokyo-imagen-flutter-demo.iam.gserviceaccount.com",
    "client_id": "114982062452563958395",
    "type": "service_account",
  });
  var scopes = ['https://www.googleapis.com/auth/cloud-platform'];

  debugPrint('...obtain credentials');
  var client = http.Client();
  AccessCredentials credentials =
      await obtainAccessCredentialsViaServiceAccount(
          accountCredentials, scopes, client);

  client.close();

  debugPrint('Succeeded to get the service account credentials');
  return credentials;
}

FutureOr<ImagenResponse> generateImage() async {
  final credentials = await obtainCredentials();

  Map<String, String> headers = {
    "Authorization": "Bearer ${credentials.accessToken.data}",
    "Content-Type": "application/json; charset=utf-8"
  };

  var body = {
    "instances": [
      {
        "prompt":
            "a beautiful and glamorous female fashion model with a dog is taken her portrait photo at the central park in Summer",
      }
    ],
    "parameters": {
      "sampleCount": 2,
      "aspectRatio": "1:1",
      "outputOptions": {
        "mimeType": "image/png",
        "compressionQuality": 80,
      },
    }
  };

  debugPrint('...calling Imagen 3 API');
  try {
    final res = await http.post(
      Uri.https(
        'us-central1-aiplatform.googleapis.com',
        'v1/projects/next-tokyo-imagen-flutter-demo/locations/us-central1/publishers/google/models/imagen-3.0-generate-preview-0611:predict',
      ),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      ImagenResponse imagenResponse =
          ImagenResponse.fromJson(jsonDecode(res.body));

      debugPrint('Succeeded to generate iamges');
      return imagenResponse;
    }
  } catch (e) {
    throw Exception(e.toString());
  }

  throw Exception('Failed to generate images');
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var image = '';

  Future<void> handleGenerate() async {
    final generatedImage = await generateImage();

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
    return MaterialApp(
      home: Scaffold(
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
      ),
    );
  }
}
