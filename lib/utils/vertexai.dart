import "dart:async";
import "dart:convert";

import "package:flutter/material.dart";
import "package:google_next_imagen_demo/models/imagen_resopnse.dart";
import "package:google_next_imagen_demo/utils/obtain_credentials.dart";
import "package:http/http.dart" as http;

class VertexAI {
  FutureOr<ImagenResponse> generateImage(prompt) async {
    final credentials = await obtainCredentials();

    Map<String, String> headers = {
      "Authorization": "Bearer ${credentials.accessToken.data}",
      "Content-Type": "application/json; charset=utf-8"
    };

    var body = {
      "instances": [
        {
          "prompt": "$prompt",
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

  FutureOr<ImagenResponse> editImage(prompt, image) async {
    final credentials = await obtainCredentials();

    Map<String, String> headers = {
      "Authorization": "Bearer ${credentials.accessToken.data}",
      "Content-Type": "application/json; charset=utf-8"
    };

    var body = {
      "instances": [
        {
          "prompt": "$prompt",
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
}
