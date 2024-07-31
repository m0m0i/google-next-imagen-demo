import "dart:async";
import "dart:convert";
import "dart:typed_data";

import "package:googleapis_auth/auth_io.dart";

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

    String updatedPrompt = await updatePrompt(prompt, credentials);

    var body = {
      "instances": [
        {
          "prompt": updatedPrompt,
        }
      ],
      "parameters": {
        "sampleCount": 4,
        "aspectRatio": "1:1",
        "outputOptions": {
          "mimeType": "image/png",
        },
        "safetySettings": "block_most"
      }
    };

    try {
      final res = await http.post(
        Uri.https(
          'us-central1-aiplatform.googleapis.com',
          'v1/projects/next-tokyo-imagen-flutter-demo/locations/us-central1/publishers/google/models/imagen-3.0-generate-001:predict',
        ),
        headers: headers,
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        ImagenResponse imagenResponse =
            ImagenResponse.fromJson(jsonDecode(res.body));

        return imagenResponse;
      } else {
        debugPrint('Error: ${res.statusCode} - ${res.body}');
        throw Exception('Failed to generate the image');
      }
    } catch (e) {
      debugPrint('Error generate image: $e');
      throw Exception('Failed to generate the image');
    }
  }

  FutureOr<ImagenResponse> editImage(String prompt, Uint8List image) async {
    final credentials = await obtainCredentials();

    Map<String, String> headers = {
      "Authorization": "Bearer ${credentials.accessToken.data}",
      "Content-Type": "application/json; charset=utf-8"
    };

    String updatedPrompt = await updatePrompt(prompt, credentials);

    var body = {
      "instances": [
        {
          "prompt": updatedPrompt,
          "image": {
            "bytesBase64Encoded": base64Encode(image),
          }
        }
      ],
      "parameters": {
        "sampleCount": 4,
        "aspectRatio": "1:1",
        "editConfig": {
          "editMode": "product-image",
        },
        "outputOptions": {
          "mimeType": "image/png",
        },
      }
    };

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

  FutureOr<GeminiResponse> copyWriting(String prompt, String image) async {
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
              "data": image,
            }
          },
          {
            "text": prompt,
          }
        ]
      },
      "safety_settings": {"threshold": "BLOCK_LOW_AND_ABOVE"}
    };

    try {
      final res = await http.post(
        Uri.https(
          'us-central1-aiplatform.googleapis.com',
          'v1/projects/next-tokyo-imagen-flutter-demo/locations/us-central1/publishers/google/models/gemini-1.5-flash-001:generateContent',
        ),
        headers: headers,
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        GeminiResponse geminiResponse =
            GeminiResponse.fromJson(jsonDecode(res.body));

        return geminiResponse;
      }
    } catch (e) {
      debugPrint('Failed to call Gemini 1.5 Flash');
      throw Exception(e.toString());
    }

    throw Exception('Failed to generate text');
  }

  FutureOr<String> updatePrompt(
      String prompt, AccessCredentials credentials) async {
    Map<String, String> headers = {
      "Authorization": "Bearer ${credentials.accessToken.data}",
      "Content-Type": "application/json; charset=utf-8"
    };

    var body = {
      "contents": {
        "role": "USER",
        "parts": [
          {
            "text": '''
              You are the excellent prompt generator to get the best results from Google Cloud Vertex Imagen API.
              Your mission is to translate the Japanese to English and create the best prompt to get the most fitted images to the original prompt.

              If violent or offensive concepts or similar words are entered that violate your ethical guidelines, immediately respond with a blank response.

              The generated prompt must be optimized to generate realistic, photographic and impactful images.
              
              The response should return only one prompt that is passed to imagen.

              expamle:
              ・close up photo of a woman in her 20s, street photography, canon, movie still, muted orange warm tones
              ・A sketch of a modern apartment building surrounded by skyscrapers
              ・soft focus photograph of a bridge in an urban city at night
              ・street photography, new york city, fisheye lens
              ・4k HDR beautiful photo of a corn stalk taken by a professional photographer
              ・A professional studio photo of french fries for a high end restaurant, in the style of a food magazine
              ・a woman hiking, close of her boots reflected in a puddle, large mountains in the background, in the style of an advertisement, dramatic angles


              input: $prompt
            ''',
          }
        ]
      },
      "safety_settings": {"threshold": "BLOCK_LOW_AND_ABOVE"}
    };

    try {
      final res = await http.post(
        Uri.https(
          'us-central1-aiplatform.googleapis.com',
          'v1/projects/next-tokyo-imagen-flutter-demo/locations/us-central1/publishers/google/models/gemini-1.5-flash-001:generateContent',
        ),
        headers: headers,
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        GeminiResponse geminiResponse =
            GeminiResponse.fromJson(jsonDecode(res.body));

        return geminiResponse.candidates[0].content.parts[0].text;
      }
    } catch (e) {
      debugPrint('Failed to call Gemini 1.5 Flash');
      throw Exception(e.toString());
    }

    throw Exception('Failed to generate better prompt');
  }
}
