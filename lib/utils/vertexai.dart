import "dart:async";
import "dart:convert";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:google_next_imagen_demo/models/gemini_response.dart";
import "package:google_next_imagen_demo/models/imagen_resopnse.dart";
import "package:google_next_imagen_demo/utils/obtain_credentials.dart";
import "package:http/http.dart" as http;

class VertexAI {
  FutureOr<ImagenResponse> generateImage(String prompt) async {
    final credentials = await obtainCredentials();

    Map<String, String> headers = {
      "Authorization": "Bearer ${credentials.accessToken.data}",
      "Content-Type": "application/json; charset=utf-8"
    };

    var body = {
      "instances": [
        {
          "prompt": prompt,
        }
      ],
      "parameters": {
        "sampleCount": 1,
        "aspectRatio": "1:1",
        "outputOptions": {
          "mimeType": "image/png",
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
      } else {
        debugPrint('Error: ${res.statusCode} - ${res.body}');
        throw Exception('Failed to edit image');
      }
    } catch (e) {
      debugPrint('Error editing image: $e');
      throw Exception('Failed to edit image');
    }
  }

  FutureOr<ImagenResponse> editImage(String prompt, Uint8List image) async {
    final credentials = await obtainCredentials();

    Map<String, String> headers = {
      "Authorization": "Bearer ${credentials.accessToken.data}",
      "Content-Type": "application/json; charset=utf-8"
    };

    var body = {
      "instances": [
        {
          "prompt": prompt,
          "image": {
            "bytesBase64Encoded": base64Encode(image),
          }
        }
      ],
      "parameters": {
        // "sampleCount": 1,
        "aspectRatio": "1:1",
        "editConfig": {
          // Comment out the following two lines when using the Product Image Editing mode
          "editMode": "inpainting-insert",
          "maskMode": {"maskType": "background"},
          // Uncomment the following to use the Product Image Editing mode
          // "editMode": "product-image",
        },
        "outputOptions": {
          "mimeType": "image/png",
        },
      }
    };

    debugPrint('...calling Imagen 2 API');
    try {
      final res = await http.post(
        Uri.https(
          'us-central1-aiplatform.googleapis.com',
          'v1/projects/next-tokyo-imagen-flutter-demo/locations/us-central1/publishers/google/models/imagegeneration@006:predict',
        ),
        headers: headers,
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        ImagenResponse imagenResponse =
            ImagenResponse.fromJson(jsonDecode(res.body));

        debugPrint('Succeeded to generate iamges');
        return imagenResponse;
      } else {
        debugPrint('Error: ${res.statusCode} - ${res.body}');
        throw Exception('Failed to edit image');
      }
    } catch (e) {
      debugPrint('Error editing image: $e');
      throw Exception('Failed to edit image');
    }
  }

  FutureOr<GeminiResponse> CopyWriting(prompt, image) async {
    final credentials = await obtainCredentials();

    Map<String, String> headers = {
      "Authorization": "Bearer ${credentials.accessToken.data}",
      "Content-Type": "application/json; charset=utf-8"
    };

    var body = {
        "contents": {
          "role": "USER",
          "parts": [
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "$image"
              }
            },
            {
              "text": "$prompt"
            }
          ]
        }
      };

    debugPrint('...calling Gemini API');

    try {
      final res = await http.post(
        Uri.https(
          'us-central1-aiplatform.googleapis.com',
          'v1/projects/next-tokyo-imagen-flutter-demo/locations/us-central1/publishers/google/models/gemini-1.5-pro-preview-0409:generateContent',
        ),
        headers: headers,
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        GeminiResponse geminiResponse =
            GeminiResponse.fromJson(jsonDecode(res.body));

        debugPrint('Succeeded to generate text');
        return geminiResponse;
      }
    } catch (e) {
      debugPrint('Failed to call Gemini API');
      throw Exception(e.toString());
    }

    throw Exception('Failed to generate text');
  }
}
